import std/[strutils, sugar, paths, dirs, htmlparser]
# import pretty
# TODO: use my own markdown parser when ready
# import md
import markdown
import karax/[karaxdsl, vdom]

# TODO: convert to inputs?
const
  mdDir = "./md".Path
  outDir = "./gen".Path

type
  Route = object
    name: string
    friendlyName: string
    src: Path
    dst: Path
    uri: Path

proc toFriendlyName*(x: string): string =
  result.setLen(x.len)
  for i in 0..<len(x):
    if x[i] == '_':
      result[i] = ' '
    elif x[i] in LowercaseLetters and (i == 0 or result[i - 1] == ' '):
      result[i] = x[i].toUpperAscii
    else:
      result[i] = x[i]

proc genRoute(r: Route) =
  let src = readFile(r.src.string)
  echo r.src.string, " -> ", r.dst.string
  let 
    # TODO: use my own md parser
    content = markdown(src, config=initGfmConfig())
    outputHtml = buildHtml(html(lang = "en")):
      head:
        title: text "miguel's blog"
      body:
        text "TODO"
        main(class="max-w-2xl mx-auto"):
          verbatim(content)
    outDir = r.dst.splitFile.dir
  
  doAssert outDir.existsOrCreateDir(), outDir.string
  writeFile(r.dst.string, $outputHtml)

proc genSite =
  let mdFiles = collect:
    for x in mdDir.walkDirRec:
      let p = x.splitFile
      if p.ext == ".md":
        (p, x)

  let routes = collect:
    for (x, src) in mdFiles:
      let 
        relPath = src.relativePath(mdDir)
        uri = relPath.changeFileExt("html")
        dst = outDir / uri
        friendlyName = x.name.string.toFriendlyName

      Route(
        name: x.name.string,
        friendlyName: friendlyName,
        src: src,
        dst: dst,
        uri: uri,
      )

  for r in routes:
    genRoute(r)

genSite()
