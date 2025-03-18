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
    mimetypes
  ],
  karax/[karaxdsl, vdom, vstyles],
  md4c,
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

type
  SimpleYaml = Table[string, string]
  RouteKind = enum  
    rkPage
    rkBlogPost
    rkPrivateNote

  Ctx = object
    silent: bool

    privateNotes: bool
    inpDir: Path
    outDir: Path
    staticDir: Path

    serve: bool
    dev: bool
    port: int

  Route = object
    case kind: RouteKind
    of rkPage, rkPrivateNote:
      discard
    of rkBlogPost:
      readingTimeMins: float

    dt: DateTime
    title: string
    name: string
    friendlyName: string
    src: Path
    dst: Path
    uri: Path
    info: FileInfo

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

    mdData = if endIdx != -1:
      mdFile[(endIdx + 4) .. ^ 1]
    else:
      doAssert startIdx == -1
      mdFile

  result.md = mdData
  result.yaml = if yamlData != "":
    parseYamlSimple(yamlData)
  else:
    SimpleYaml()

proc css(ctx: Ctx): VNode =
  result = buildHtml(html):
    link(rel="icon", type="image/x-icon", href="/images/icon.svg")
    link(rel="stylesheet", href="/style.css")

proc navBar(ctx: Ctx): VNode =
  result = buildHtml(html):
    nav:
      ul:
        li: a(href="/"): text "home"
        li: a(href="/blog"): text "blog"
        if ctx.privateNotes:
          li: a(href="/notes"): text "notes"
      tdiv:
        h1: a(href="/"): text "miguel"

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

proc genRoute(ctx: Ctx, r: var Route) =
  let src = readFile(r.src.string)
  if not ctx.silent:
    echo r.src.string, " -> ", r.dst.string

  let 
    (md, yaml) = splitMdAndYaml(src)
    content = mdToHtml(md)
    title = yaml.getOrDefault("title", r.friendlyName)
    dt = yaml.getOrDefault("date", now().format("yyyy-MM-dd"))
  
  r.title = title
  r.dt = parse(dt, "yyyy-MM-dd", local())

  let
    info = getFileInfo(r.src.string)
    # ~4.7 chars per word
    # assume markdown is ~2x # bytes
    # 238 average wpm reading
    ttr = max(1, parseInt(yaml.getOrDefault("time-to-read", &"{info.size div (5 * 2 * 230)}")))
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
              h1: text r.title
              tdiv(class="times"):
                pre: text format(r.dt, "MMMM d, yyyy")
                if ttr == 1:
                  pre: text &"Time to read: {ttr} min"
                else:
                  pre: text &"Time to read: {ttr} mins"

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
            if r.kind == rkPrivateNote:
              li: 
                pre(style={display: "inline"}): text format(r.dt, "yyyy-MM-dd")
                tdiv(class="hspace")
                a(href=r.uri.string): text r.title

  writeFile(
    (ctx.outDir / Path("notes.html")).string,
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
        ul:
          for r in routes:
            if r.kind == rkBlogPost:
              li: 
                pre(style={display: "inline"}): text format(r.dt, "yyyy-MM-dd")
                tdiv(class="hspace")
                a(href=r.uri.string): text r.title

  writeFile(
    (ctx.outDir / Path("blog.html")).string,
    "<!DOCTYPE html>\n\n" & $outputHtml,
  )

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
      fp = ctx.outDir / relPathSplit.dir / Path(relPathSplit.name.string & ext)
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
      copyDir(ctx.staticDir.string, ctx.outDir.string)

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

proc genSite(
  inpDir = "./md",
  outDir = "./dist",
  staticDir = "./static",
  silent = false,
  dev = false,
  serve = false,
  port = 3000,
  privateNotes = false,
) =
  let 
    inpDir = Path(inpDir)
    outDir = Path(outDir)
    staticDir = Path(staticDir)
    ctx = Ctx(
      silent: silent,
      privateNotes: privateNotes,
      inpDir: inpDir,
      outDir: outDir,
      staticDir: staticDir,
      serve: serve,
      port: port,
      dev: dev,
    )

    followFilter = if privateNotes:
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
        kind: if "blog" in relPath.string:
          rkBlogPost
        elif "private" in relPath.string:
          rkPrivateNote
        else:
          rkPage
        ,
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

  if serve:
    runServer(ctx, routes)

when isMainModule:
  import cligen
  dispatch(genSite, help={
    "inpDir": "input directory",
    "outDir": "output directory",
    "serve": "server locally?",
    "port": "port to serve on",
  })
