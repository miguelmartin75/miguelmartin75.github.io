import 
  std/[strutils, sugar, paths, dirs, htmlparser, tables],
  markdown,
  karax/[karaxdsl, vdom]
  # yaml

type
  SimpleYaml = Table[string, string]
  Route = object
    name: string
    friendlyName: string
    src: Path
    dst: Path
    uri: Path

proc parseYamlSimple(inp: string): SimpleYaml = 
  for line in inp.splitLines:
    if line.len == 0:
      continue

    let sp = line.split(": ")
    doAssert sp.len == 2

    var 
      k = sp[0]
      v = sp[1]
    if v.startsWith('"'):
      doAssert v.endsWith('"')
      v = v[1..^2]
    result[k] = v

proc toFriendlyName*(x: string): string =
  result.setLen(x.len)
  for i in 0..<len(x):
    if x[i] == '_':
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

    yamlData = if endIdx != -1:
      doAssert startIdx != -1
      mdFile[(startIdx + 3).. endIdx] 
    else:
      ""

    mdData = if endIdx != -1:
      mdFile[(endIdx + 3) .. ^ 1]
    else:
      doAssert startIdx == -1
      mdFile

  result.md = mdData
  result.yaml = if yamlData != "":
    parseYamlSimple(yamlData)
  else:
    SimpleYaml()

proc genRoute(r: Route, silent: bool) =
  let src = readFile(r.src.string)
  if not silent:
    echo r.src.string, " -> ", r.dst.string

  let 
    (md, yaml) = splitMdAndYaml(src)

    # TODO: use my own md parser
    content = markdown(md, config=initGfmConfig())
    outputHtml = buildHtml(html(lang = "en")):
      head:
        title: text yaml.getOrDefault("title", r.friendlyName)

      body:
        text "TODO"
        main(class="max-w-2xl mx-auto"):
          verbatim(content)
    outDir = r.dst.splitFile.dir
  
  doAssert outDir.existsOrCreateDir(), outDir.string
  writeFile(r.dst.string, $outputHtml)

proc genSite(inpDir = "./md", outDir = "./dist", silent = false) =
  let 
    inpDir = Path(inpDir)
    outDir = Path(outDir)
    mdFiles = collect:
      for x in inpDir.walkDirRec:
        let p = x.splitFile
        if p.ext == ".md":
          (p, x)

  let routes = collect:
    for (x, src) in mdFiles:
      let 
        relPath = src.relativePath(inpDir)
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
    genRoute(r, silent)

  # TODO: create posts, index, archive, bio, etc.

when isMainModule:
  import cligen
  dispatch(genSite, help={
    "inpDir": "input directory",
    "outDir": "output directory",
  })
