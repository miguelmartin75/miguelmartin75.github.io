import
  std/[
    algorithm,
    times,
    os,
    sets,
    monotimes,
    strformat,
    strutils,
    sequtils,
    dirs,
    files,
    sugar,
    paths,
    tables,
    mimetypes,
    xmltree,
    strtabs,
    unicode,
  ],
  karax/[karaxdsl, vdom, vstyles, xdom],
  md4c,
  htmlparser,
  mummy, mummy/routers

const mimeDb = newMimeTypes()

template resp(code: int, contentType: string, r: untyped): untyped =
  var headers: HttpHeaders
  headers["Content-Type"] = contentType
  request.respond(code, headers, r)

proc nowMs*(): float64 = getMonoTime().ticks.float64 / 1e6
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

proc toString(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

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
    baseUrl: string = "https://miguelmartin75.github.io"
    siteTitle: string = "Miguel's Blog"

  Route = object
    kind: RouteKind
    isPrivate: bool
    readingTimeMins: float

    dt: DateTime
    title: string
    name: string
    friendlyName: string
    src: Path
    dst: Path
    uri: Path
    info: FileInfo
    yaml: SimpleYaml

const defaultCtx = Ctx(
  silent: false,
  privateNotes: false,
  inpDir: "./md",
  outDir: "./dist",
  staticDir: "./static",
  serve: false,
  dev: false,
  port: 3000,
  baseUrl: "https://miguelmartin75.github.io",
  siteTitle: "Miguel's Blog",
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
    if x[i] == '_':
      result[i] = ' '
    elif x[i] == '-':
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
      doAssert startIdx != -1
      mdFile[(startIdx + 3).. endIdx]
    else:
      ""

    mdData = if endIdx != -1 and startIdx == 0:
      mdFile[(endIdx + 4) .. ^ 1]
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

proc toString(node: XmlNode): string =
  result.add(node, indent=0, indWidth=0, addNewLines=true)

proc innerHtml(node: XmlNode): string =
  for n in node:
    result &= $n

proc innerTextOnly(node: XmlNode): string =
  proc traverse(res: var string, n: XmlNode) =
    case n.kind:
    of xnText:
      res.add(n.innerText)
    of xnElement:
      case n.tag:
      of "x-equation":
        return
      else:
        for sub in n:
          traverse(res, sub)
    else:
      return

  traverse(result, node)

proc postProcessHtml(html: string): string =
  result = ""
  
  var assignedIds: HashSet[string]
  proc dfs(node: XmlNode) =
    if node.kind != xnElement:
      return

    case node.tag:
    of "h1", "h2", "h3", "h4", "h5", "h6":
      if node.attrs.isNil:
        node.attrs = newStringTable()

      let innerText = node.innerTextOnly

      var id = innerText
        .toLower
        .filter(proc(x: char): bool =
          x in Digits or x in LowercaseLetters or x in {'-', ' '}
        ).toString
        .strip(leading=true, trailing=false, Digits)
        .strip(leading=true, trailing=true, {' '})
        .replace(" ", "-")

      if id in assignedIds:
        stderr.writeLine &"[WARN]: {id} header is already assigned"

      block:
        var 
          i = 1
          newId = id
        while newId in assignedIds or newId == "":
          newId = id & &"{i}"
          i += 1
        id = newId
        
      doAssert id notin assignedIds, &"{id} is not unique - choose another header"
      assignedIds.incl(id)

      let
        link = "#" & id
        innerContent = node.innerHtml
        # aTag = newXmlTree("a", [newText(node.innerText)], {"href": link}.toXmlAttributes)
        aTag = buildHtml(html):
          a(href=link):
            verbatim(innerContent)

      node.attrs["id"] = id
      node.replace(0..<node.len, [aTag.toXmlNode])
    else:
      discard
    
    for child in node:
      dfs(child)
  
  var dom = parseHtml(html)
  dfs(dom)

  result = dom.toString

proc genRoute(ctx: Ctx, r: var Route) =
  let src = readFile(r.src.string)
  if not ctx.silent:
    echo r.src.string, " -> ", r.dst.string

  let
    (md, yaml) = splitMdAndYaml(src)
    mdHtml = mdToHtml(md)
    content = postProcessHtml(mdHtml)
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

  discard outDir.existsOrCreateDir()
  writeFile(r.dst.string, "<!DOCTYPE html>\n\n" & $outputHtml)

proc genNotes(ctx: Ctx, routes: seq[Route]) =
  let outputHtml = buildHtml(html(lang = "en")):
    head:
      title: text "Miguel's Notes (private)"
      css(ctx)
    body:
      navBar(ctx)
      main:
        ul:
          for r in routes:
            if r.kind == rkNote:
              li:
                pre(style={display: "inline"}): text format(r.dt, "yyyy-MM-dd")
                tdiv(class="hspace")
                a(href=r.uri.string): text r.title

  writeFile(
    (Path(ctx.outDir) / Path("notes.html")).string,
    "<!DOCTYPE html>\n\n" & $outputHtml,
  )

proc genBlog(ctx: Ctx, routes: seq[Route]) =
  let outputHtml = buildHtml(html(lang = "en")):
    head:
      title: text "Miguel's Blog"
      css(ctx)
    body:
      navBar(ctx)
      main:
        rssButton()
        ul:
          for r in routes:
            if r.kind == rkBlogPost and r.yaml.getOrDefault("state", "draft") != "draft":
              li:
                pre(style={display: "inline"}): text format(r.dt, "yyyy-MM-dd")
                tdiv(class="hspace")
                a(href=r.uri.string): text r.title

  writeFile(
    (Path(ctx.outDir) / Path("blog.html")).string,
    "<!DOCTYPE html>\n\n" & $outputHtml,
  )

proc extractSummary(md: string; maxLen = 300): string =
  ## Converts markdown to HTML then extracts inner text and truncates.
  let html = mdToHtml(md)
  let dom = parseHtml(html)
  var buf = ""
  for n in dom:
    buf.add(n.innerText)
  result = buf.strip
  if result.len > maxLen:
    result = result[0 ..< maxLen].strip & "…"

proc rssDate(dt: DateTime): string =
  result = dt.format("ddd, dd MMM yyyy HH:mm:ss zzz")

proc genRss(ctx: Ctx, routes: seq[Route]) =
  var posts = collect:
    for r in routes:
      if r.kind == rkBlogPost and not r.isPrivate and r.yaml.getOrDefault("state", "draft") != "draft":
        r

  posts.sort(proc(a, b: Route): int = -cmp(a.dt, b.dt))

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
      pubDate = rssDate(r.dt)
      summary = extractSummary(parts.md)

    # Basic escaping for XML text nodes
    proc xesc(s: string): string =
      result = s
      result = result.replace("&", "&amp;")
      result = result.replace("<", "&lt;")
      result = result.replace(">", "&gt;")
      result = result.replace("\"", "&quot;")
      result = result.replace("'", "&apos;")

    xml.add("    <item>\n")
    xml.add(&"      <title>{xesc(title)}</title>\n")
    xml.add(&"      <link>{xesc(link)}</link>\n")
    xml.add(&"      <guid>{xesc(guid)}</guid>\n")
    xml.add(&"      <pubDate>{xesc(pubDate)}</pubDate>\n")
    if summary.len > 0:
      xml.add(&"      <description>{xesc(summary)}</description>\n")
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

  proc assetHandler(request: Request) =
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

      mime = getMimetype(mimeDb, ext, "")
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

    if not fp.fileExists:
      handleCode(404)
      return

    if mime == "":
      handleCode(403)
      return

    var headers: HttpHeaders
    headers["Content-Type"] = mime

    let content = readFile(fp.string)
    request.respond(200, headers, content)

    if ctx.dev:
      copyDir(ctx.staticDir, ctx.outDir)

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
    staticDir = Path(ctx.staticDir)

    followFilter = if ctx.privateNotes:
      {pcDir, pcLinkToDir}
    else:
      {pcDir}
    mdFiles = collect:
      for x in inpDir.walkDirRec(followFilter=followFilter):
        let p = x.splitFile
        if p.ext == ".md":
          (p, x)

  copyDir(staticDir.string, outDir.string)

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

  discard outDir.existsOrCreateDir()
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
  var ctx = initFromCL(defaultCtx)
  ctx.genSite()
