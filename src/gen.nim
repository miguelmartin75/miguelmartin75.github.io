import std/[strutils, sugar, paths, dirs]
import md
import pretty

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
  for node in mdParse(src):
    continue

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
