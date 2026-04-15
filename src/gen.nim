import
  std/[
    algorithm,
    times,
    os,
    monotimes,
    strformat,
    strutils,
    dirs,
    files,
    sugar,
    paths,
    tables,
    mimetypes,
  ],
  karax/[karaxdsl, vdom, vstyles],
  highlight_config,
  md4c,
  treesitter/highlight,
  mummy, mummy/routers

include "style.css.nimf"

type
  SimpleYaml = Table[string, string]
  RouteKind = enum
    rkPage
    rkBlogPost
    rkNote

  Ctx = object
    silent: bool = false

    privateNotes: bool = false
    inpDir: string = "./md"
    outDir: string = "./dist"
    staticDir: string = "./static"

    serve: bool = false
    dev: bool = false
    port: int = 3000
    baseUrl: string = "https://miguelmartin.com"
    siteTitle: string = "Miguel's Blog"
    highlightTheme: string = "zenbones"

  Route = object
    kind: RouteKind
    isPrivate: bool

    dt: DateTime
    title: string
    name: string
    friendlyName: string
    src: Path
    dst: Path
    uri: Path
    yaml: SimpleYaml

const MimeDb = newMimeTypes()

proc css(ctx: Ctx): VNode
proc navBar(ctx: Ctx): VNode
proc rssButton(): VNode

proc nowMs*(): float64 =
  result = getMonoTime().ticks.float64 / 1e6

proc xmlEscaped(s: string): string =
  result.addHtmlEscaped(s)

template resp(code: int, contentType: string, r: untyped): untyped =
  var headers: HttpHeaders
  headers["Content-Type"] = contentType
  request.respond(code, headers, r)

template echoMs*(prefix: string, silent: bool, body: untyped) =
  let t1 = nowMs()
  body
  let
    t2 = nowMs()
    delta = t2 - t1

  if not silent:
    var deltaStr = ""
    deltaStr.formatValue(delta, ".3f")
    echo prefix, deltaStr, "ms"

template writeRouteListPage(
  ctx: Ctx,
  pageTitle, outName: string,
  includeRssButton: bool,
  items: untyped,
): untyped =
  let outputHtml = buildHtml(html(lang = "en")):
    head:
      title: text pageTitle
      css(ctx)
    body:
      navBar(ctx)
      main:
        if includeRssButton:
          rssButton()
        ul:
          items

  writeFile(
    (Path(ctx.outDir) / Path(outName)).string,
    "<!DOCTYPE html>\n\n" & $outputHtml,
  )

proc parseYamlSimple(inp: string): SimpleYaml =
  for line in inp.splitLines:
    if line.len == 0:
      continue

    let sp = line.split(": ")
    doAssert sp.len >= 1, $sp

    var
      k = sp[0]
      v = if sp.len >= 2:
        sp[1..^1].join(": ")
      else:
        ""

    if v.startsWith('"'):
      doAssert v.endsWith('"')
      v = v[1..^2]
    result[k] = v

proc toFriendlyName*(x: string): string =
  result.setLen(x.len)
  for i in 0..<len(x):
    if x[i] in {'_', '-'}:
      result[i] = ' '
    elif x[i] in LowercaseLetters and (i == 0 or result[i - 1] == ' '):
      result[i] = x[i].toUpperAscii
    else:
      result[i] = x[i]

proc splitMdAndYaml(mdFile: string): tuple[md: string, yaml: SimpleYaml] =
  let
    startIdx = mdFile.find("---")
    endIdx = if startIdx != -1:
      mdFile.find("---", startIdx + 3) - 1
    else:
      startIdx

    yamlData = if endIdx != -1 and startIdx == 0:
      mdFile[(startIdx + 3)..endIdx]
    else:
      ""

    mdData = if endIdx != -1 and startIdx == 0:
      mdFile[(endIdx + 4)..^1]
    else:
      mdFile

  result.md = mdData
  result.yaml = if yamlData != "":
    parseYamlSimple(yamlData)
  else:
    SimpleYaml()

proc css(ctx: Ctx): VNode =
  result = buildHtml(html):
    meta(name="viewport", content="width=device-width, initial-scale=1.0")
    link(rel="icon", type="image/x-icon", href="/images/icon.svg")
    link(rel="stylesheet", href="/style.css")
    link(rel="alternate", type="application/rss+xml", title="RSS", href="/rss.xml")

proc navBar(ctx: Ctx): VNode =
  result = buildHtml(html):
    nav:
      ul:
        li: a(href="/blog"): text "blog"
        if ctx.privateNotes:
          li: a(href="/notes"): text "notes"
      ul:
        li: a(href="/"): text "miguel"

proc rssButton(): VNode =
  result = buildHtml(html):
    tdiv(class="rss-button-container"):
      a(
        href="/rss",
        title="Subscribe via RSS",
        class="rss-button",
      ):
        verbatim("""
<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M3.00024 13.0225C8.18522 12.2429 11.7559 15.8146 10.9774 20.9996M3.00024 8.03784C10.938 7.25824 16.7417 13.0619 15.9621 20.9997M3.00024 3.05212C13.6919 2.27364 21.7264 10.3082 20.948 20.9998M5 21C3.89566 21 3 20.1043 3 19C3 17.8957 3.89566 17 5 17C6.10434 17 7 17.8957 7 19C7 20.1043 6.10434 21 5 21Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
        """)

proc commentsSection(): VNode =
  result = buildHtml(html):
    verbatim("""
<script
  src="https://utteranc.es/client.js"
  repo="miguelmartin75/miguelmartin75.github.io"
  issue-term="title"
  label="💬"
  theme="github-light"
  crossorigin="anonymous"
  async>
</script>
""")

proc copyStaticAssets(staticDir, outDir: string) =
  if not dirExists(staticDir):
    return

  discard outDir.existsOrCreateDir()
  for src in walkDirRec(staticDir):
    let relPath = src.relativePath(staticDir)
    if relPath == "style.css":
      continue

    let
      dst = outDir / relPath
      dstDir = dst.parentDir

    if dstDir.len > 0:
      discard dstDir.existsOrCreateDir()
    copyFile(src, dst)

proc writeStylesheet(ctx: Ctx) =
  let
    theme = loadSyntaxTheme(ctx.highlightTheme)
    tokenCss = renderSyntaxTokenCss(theme)
    stylesheet = renderStyleCss(theme.name, theme.codeBg, theme.codeBorder, tokenCss)

  writeFile((Path(ctx.outDir) / Path("style.css")).string, stylesheet)

proc datedRouteListItem(r: Route): VNode =
  result = buildHtml(li):
    pre(style={display: "inline"}): text format(r.dt, "yyyy-MM-dd")
    tdiv(class="hspace")
    a(href=r.uri.string): text r.title

proc genRoute(ctx: Ctx, r: var Route) =
  let src = readFile(r.src.string)
  if not ctx.silent:
    echo r.src.string, " -> ", r.dst.string

  let
    (md, yaml) = splitMdAndYaml(src)
    content = mdToHtml(md, outputOptions = HtmlOutputOptions(codeBlock: highlightedCodeBlockOutput))
    title = yaml.getOrDefault("title", r.friendlyName)
    dt = yaml.getOrDefault("date", now().format("yyyy-MM-dd"))

  r.title = title
  r.dt = parse(dt, "yyyy-MM-dd", local())
  r.yaml = yaml

  let
    info = getFileInfo(r.src.string)
    # ~4.7 chars per word
    # assume markdown is ~1.25x # bytes
    # 238 average wpm reading
    readingTimeMins = max(1, parseInt(yaml.getOrDefault("time-to-read", &"{info.size div (5 * 1.2 * 230).int}")))
    outputHtml = buildHtml(html(lang = "en")):
      head:
        title: text title
        verbatim("""
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.21/dist/katex.min.css" integrity="sha384-zh0CIslj+VczCZtlzBcjt5ppRcsAmDnRem7ESsYwWwg3m/OaJ2l4x7YBZl9Kxxib" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.21/dist/katex.min.js" integrity="sha384-Rma6DA2IPUwhNxmrB/7S3Tno0YY7sFu9WSYMCuulLhIqYSGZ2gKCJWIqhBWqMQfh" crossorigin="anonymous"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
  const macros = {};

  let mathElements = document.getElementsByTagName("x-equation");
  for (let element of mathElements) {
      katex.render(element.textContent, element, {
          throwOnError: false,
          macros
      });
  }
  })
</script>
""")
        css(ctx)

      body:
        navBar(ctx)
        main:
          if r.kind == rkBlogPost:
            tdiv(class="info"):
              h1(id="title"): a(href="#title"): text r.title
              tdiv(class="times"):
                pre: text format(r.dt, "MMMM d, yyyy")
                if readingTimeMins == 1:
                  pre: text &"Time to read: {readingTimeMins} min"
                else:
                  pre: text &"Time to read: {readingTimeMins} mins"

          tdiv(class="content"):
            verbatim(content)
          if r.kind == rkBlogPost:
            commentsSection()
    outDir = r.dst.splitFile.dir

  for p in outDir.parentDirs(fromRoot=true):
    discard p.existsOrCreateDir()
  writeFile(r.dst.string, "<!DOCTYPE html>\n\n" & $outputHtml)

proc genNotes(ctx: Ctx, routes: seq[Route]) =
  writeRouteListPage(ctx, "Miguel's Notes (private)", "notes.html", false):
    for r in routes:
      if r.kind == rkNote:
        datedRouteListItem(r)

proc genBlog(ctx: Ctx, routes: seq[Route]) =
  writeRouteListPage(ctx, "Miguel's Blog", "blog.html", true):
    for r in routes:
      if r.kind == rkBlogPost and r.yaml.getOrDefault("state", "draft") != "draft":
        datedRouteListItem(r)

proc extractSummary(md: string; maxLen = 300): string =
  result = mdToText(md).strip
  if result.len > maxLen:
    result = result[0..<maxLen].strip & "…"

proc genRss(ctx: Ctx, routes: seq[Route]) =
  var posts = collect:
    for r in routes:
      if r.kind == rkBlogPost and not r.isPrivate and r.yaml.getOrDefault("state", "draft") != "draft":
        r

  posts.sort(proc(a, b: Route): int =
    return -cmp(a.dt, b.dt)
  )

  let 
    channelLink = ctx.baseUrl & "/blog"
    channelTitle = ctx.siteTitle
    channelDesc = "Recent posts"

  var xml = ""
  xml.add("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  xml.add("<rss version=\"2.0\">\n")
  xml.add("  <channel>\n")
  xml.add(&"    <title>{channelTitle}</title>\n")
  xml.add(&"    <link>{channelLink}</link>\n")
  xml.add(&"    <description>{channelDesc}</description>\n")

  for r in posts:
    let 
      src = readFile(r.src.string)
      parts = splitMdAndYaml(src)
      title = r.title
      link = ctx.baseUrl & "/" & r.uri.string
      guid = link
      pubDate = r.dt.format("ddd, dd MMM yyyy HH:mm:ss zzz")
      summary = extractSummary(parts.md)

    xml.add("    <item>\n")
    xml.add(&"      <title>{xmlEscaped(title)}</title>\n")
    xml.add(&"      <link>{xmlEscaped(link)}</link>\n")
    xml.add(&"      <guid>{xmlEscaped(guid)}</guid>\n")
    xml.add(&"      <pubDate>{xmlEscaped(pubDate)}</pubDate>\n")
    if summary.len > 0:
      xml.add(&"      <description>{xmlEscaped(summary)}</description>\n")
    xml.add("    </item>\n")

  xml.add("  </channel>\n")
  xml.add("</rss>\n")

  writeFile((Path(ctx.outDir) / Path("rss.xml")).string, xml)

proc runServer(ctx: Ctx, routes: seq[Route]) =
  let silent = ctx.silent
  var
    routesByPath = collect:
      for r in routes:
        {r.uri.string: r}
    router: Router

  template handleCode(code: int) =
    let key = $code
    if key in routesByPath:
      var r {.inject.} = routesByPath[key]  # inject for strformat (&)
      echoMs(&"genRoute({r.src.string}): ", silent):
        ctx.genRoute(r)
      resp(404, "text/html", readFile(r.dst.string))
    else:
      request.respond(code)

  proc assetHandler(request: Request) {.gcsafe.} =
    let
      name = request.path
      relPath = if name == "/":
        Path("/index.html")
      else:
        Path(name)

      relPathSplit = relPath.splitFile
      realExt = relPathSplit.ext
      ext = if realExt == "":
        ".html"
      else:
        realExt

      mime = getMimetype(MimeDb, ext, "")
      fp = Path(ctx.outDir) / relPathSplit.dir / Path(relPathSplit.name.string & ext)
      key = if name == "/":
        "index"
      else:
        relPath.string[1..^1]

    if key in routesByPath:
      var r = routesByPath[key]
      if ctx.dev and r.src.string.endsWith(".md"):
        echoMs(&"genRoute({r.src.string}): ", silent):
          ctx.genRoute(r)
    elif key == "index":
      doAssert true, "please provide an index.md"
    elif key == "blog":
      ctx.genBlog(routes)
    elif key == "notes":
      ctx.genNotes(routes)

    if ctx.dev:
      copyStaticAssets(ctx.staticDir, ctx.outDir)
      ctx.writeStylesheet()

    if not fp.fileExists:
      handleCode(404)
    elif mime == "":
      handleCode(403)
    else:
      var headers: HttpHeaders
      headers["Content-Type"] = mime

      let content = readFile(fp.string)
      request.respond(200, headers, content)

  # TODO: reload
  proc websocketHandler(
    websocket: WebSocket,
    event: WebSocketEvent,
    message: Message
  ) =
    case event:
    of OpenEvent:
      discard
    of MessageEvent:
      discard
    of ErrorEvent:
      discard
    of CloseEvent:
      discard

  router.get("/**", assetHandler)

  let server = newServer(router, websocketHandler)
  echo &"http://localhost:{ctx.port}"
  server.serve(Port(ctx.port))

proc genSite(ctx: Ctx) =
  let
    inpDir = Path(ctx.inpDir)
    outDir = Path(ctx.outDir)

    followFilter = if ctx.privateNotes:
      {pcDir, pcLinkToDir}
    else:
      {pcDir}
    mdFiles = collect:
      for x in inpDir.walkDirRec(followFilter=followFilter):
        let p = x.splitFile
        if p.ext == ".md":
          (p, x)

  var routes = collect:
    for (x, src) in mdFiles:
      let
        relPath = src.relativePath(inpDir)
        uri = relPath.changeFileExt("")
        dst = outDir / uri.changeFileExt(".html")
        friendlyName = x.name.string.toFriendlyName

      Route(
        kind: if "blog" in relPath.string or "post" in relPath.string:
          rkBlogPost
        elif "note" in relPath.string:
          rkNote
        else:
          rkPage
        ,
        isPrivate: "private" in relPath.string,
        name: x.name.string,
        friendlyName: friendlyName,
        src: src,
        dst: dst,
        uri: uri,
      )

  copyStaticAssets(ctx.staticDir, ctx.outDir)
  discard outDir.existsOrCreateDir()
  ctx.writeStylesheet()
  for r in routes.mitems:
    ctx.genRoute(r)

  routes.sort(proc(a, b: Route): int =
    if a.kind == rkPage:
      return 0
    elif b.kind == rkPage:
      return 0
    else:
      return -cmp(a.dt, b.dt)
  )
  ctx.genBlog(routes)
  ctx.genNotes(routes)
  ctx.genRss(routes)

  if ctx.serve:
    runServer(ctx, routes)

when isMainModule:
  import cligen
  var ctx = initFromCL(Ctx.default)
  ctx.genSite()
