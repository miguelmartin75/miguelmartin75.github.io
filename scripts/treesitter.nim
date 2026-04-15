import std/[algorithm, json, os, osproc, sequtils, strformat, strutils, times]

const
  DefaultTreeSitterParsersDir = "3rdparty/tree-sitter-parsers"
  LicenseCandidates = [
    "LICENSE",
    "LICENSE.txt",
    "LICENSE.md",
    "LICENSE.rst",
    "COPYING",
    "COPYING.txt",
  ]
  ReadmeCandidates = [
    "README.md",
    "README.rst",
    "README.txt",
    "README",
  ]

proc fail(msg: string): ref CatchableError = newException(CatchableError, msg)

proc stripGitSuffix(url: string): string =
  result = url
  while result.endsWith("/"):
    result.setLen(result.len - 1)
  if result.endsWith(".git"):
    result.setLen(result.len - 4)

proc detectName(parser, subdir: string): string =
  if subdir.len > 0:
    result = lastPathPart(subdir)
  else:
    result = lastPathPart(stripGitSuffix(parser))

  if result.startsWith("tree-sitter-"):
    result = result["tree-sitter-".len..^1]

proc confirm(msg: string, yes: bool): bool =
  if yes:
    result = true
  else:
    stdout.write msg & "? [y/n]: "
    stdout.flushFile()
    try:
      let line = stdin.readLine().strip()
      result = line.len > 0 and line[0].toLowerAscii() == 'y'
    except EOFError:
      result = false

proc promptLine(msg: string): string =
  stdout.write msg & ": "
  stdout.flushFile()
  result = stdin.readLine().strip()

proc ensureDir(path: string) =
  if not dirExists(path):
    createDir(path)

proc run(args: openArray[string], workDir: string = ""): string =
  let
    cmd = quoteShellCommand(args)
    (output, exitCode) = execCmdEx(cmd, options = {poUsePath}, workingDir = workDir)

  if exitCode != 0:
    raise fail(&"command failed ({exitCode}): {cmd}\n{output}")

  result = output

proc copyIfExists(src, dst: string): bool =
  if fileExists(src):
    copyFile(src, dst)
    result = true

proc copyFirstExisting(roots: openArray[string], names: openArray[string], dst: string): bool =
  for root in roots:
    for name in names:
      if copyIfExists(root / name, dst):
        return true

proc queryDir(sourceDir, subdir: string): string =
  let preferred =
    if subdir.len > 0:
      sourceDir / subdir / "queries"
    else:
      sourceDir / "queries"

  if dirExists(preferred):
    result = preferred
  elif subdir.len > 0:
    let fallback = sourceDir / "queries"
    if dirExists(fallback):
      result = fallback

proc grammarDir(sourceDir, subdir: string): string =
  if subdir.len == 0:
    result = sourceDir
  else:
    result = sourceDir / subdir

proc inferGitHeadRef(parser: string): string =
  let refs = run(["git", "ls-remote", "--symref", parser, "HEAD"])
  for line in refs.splitLines():
    if line.startsWith("ref: ") and line.endsWith("\tHEAD"):
      let refName = line["ref: ".len..<line.find('\t')]
      if refName.startsWith("refs/heads/"):
        result = refName["refs/heads/".len..^1]
      else:
        result = refName
      break

  if result.len == 0:
    raise fail(&"unable to determine default ref for parser: {parser}")

proc resolveGitRev(parser, rev: string): string =
  let refs = run(["git", "ls-remote", parser, rev & "^{}", rev])
  for line in refs.splitLines():
    let fields = line.splitWhitespace()
    if fields.len >= 2 and fields[1].endsWith("^{}"):
      result = fields[0]
      break
    elif result.len == 0 and fields.len >= 1:
      result = fields[0]

  if result.len == 0:
    result = rev

proc inferResolvedRev(parser, workDir, requestedRev: string, subtree: bool): string =
  if subtree:
    result = resolveGitRev(parser, requestedRev)
  elif requestedRev.len > 0:
    result = run(["git", "-C", workDir, "rev-parse", "HEAD"]).strip()
  else:
    if dirExists(parser / ".git"):
      result = run(["git", "-C", parser, "rev-parse", "HEAD"]).strip()

    if result.len == 0 and dirExists(workDir / ".git"):
      result = run(["git", "-C", workDir, "rev-parse", "HEAD"]).strip()

proc installParser(
  parser: string,
  name: string = "",
  path: string = "",
  rev: string = "",
  treeSitterParsersDir: string = DefaultTreeSitterParsersDir,
  yes: bool = false,
  clean: bool = false,
  subtree: bool = false,
) =
  if parser.len == 0:
    raise fail("parser must be a git URL or a local directory")

  var languageName = name
  if languageName.len == 0:
    languageName = detectName(parser, path)
    if languageName.len == 0:
      languageName = promptLine("enter the language name")
    elif not confirm(&"detected language name: \"{languageName}\", is that correct", yes):
      languageName = promptLine("enter the language name")

  if languageName.len == 0:
    raise fail("language name cannot be empty")

  if subtree and path.len > 0:
    raise fail("subtree install does not support path")

  let destDir = treeSitterParsersDir / languageName
  if dirExists(destDir):
    if clean or confirm(&"parser \"{languageName}\" already exists, reinstall", yes):
      removeDir(destDir)
    else:
      echo "skipping install"
      return

  var
    tmpDir = ""
    sourceDir = ""
    resolvedRev = rev
    effectiveRev = rev
    success = false
    subtreeAdded = false

  try:
    if subtree:
      if effectiveRev.len == 0:
        effectiveRev = inferGitHeadRef(parser)
      ensureDir(treeSitterParsersDir)
      discard run(["git", "subtree", "add", "--prefix=" & destDir, "--squash", parser, effectiveRev])
      sourceDir = destDir
      subtreeAdded = true
    elif dirExists(parser):
      sourceDir = parser.absolutePath()
    else:
      tmpDir = getTempDir() / &"tree-sitter-parser-{languageName}-{getCurrentProcessId()}-{epochTime().int64}"
      discard run(["git", "clone", parser, tmpDir])
      sourceDir = tmpDir
      if effectiveRev.len > 0:
        discard run(["git", "-C", sourceDir, "checkout", effectiveRev])

    let grammarRoot = grammarDir(sourceDir, path)
    if not dirExists(grammarRoot):
      raise fail(&"grammar path does not exist: {grammarRoot}")

    let parserSrcDir = grammarRoot / "src"
    if not dirExists(parserSrcDir):
      raise fail(&"expected source directory at: {parserSrcDir}")

    let parserC = parserSrcDir / "parser.c"
    if not fileExists(parserC):
      raise fail(&"expected parser source at: {parserC}")

    var scannerKind = "none"
    if subtree:
      if fileExists(parserSrcDir / "scanner.c"):
        scannerKind = "c"
      elif fileExists(parserSrcDir / "scanner.cc"):
        scannerKind = "cpp"
    else:
      ensureDir(treeSitterParsersDir)
      ensureDir(destDir)
      ensureDir(destDir / "src")

      let installedParserC = destDir / "src" / "parser.c"
      copyFile(parserC, installedParserC)

      if fileExists(parserSrcDir / "scanner.c"):
        let installedScannerC = destDir / "src" / "scanner.c"
        copyFile(parserSrcDir / "scanner.c", installedScannerC)
        scannerKind = "c"
      elif fileExists(parserSrcDir / "scanner.cc"):
        let installedScannerCc = destDir / "src" / "scanner.cc"
        copyFile(parserSrcDir / "scanner.cc", installedScannerCc)
        scannerKind = "cpp"

      discard copyIfExists(parserSrcDir / "node-types.json", destDir / "src" / "node-types.json")
      discard copyIfExists(grammarRoot / "tree-sitter.json", destDir / "tree-sitter.json")

    var copiedQueries: seq[string]
    let queriesSrcDir = queryDir(sourceDir, path)
    if queriesSrcDir.len > 0:
      if not subtree:
        ensureDir(destDir / "queries")
      for queryPath in toSeq(walkFiles(queriesSrcDir / "*.scm")).sorted():
        let filename = lastPathPart(queryPath)
        if not subtree:
          copyFile(queryPath, destDir / "queries" / filename)
        copiedQueries.add(filename)

    if not subtree:
      let copyRoots = [grammarRoot, sourceDir]
      discard copyFirstExisting(copyRoots, ReadmeCandidates, destDir / "README.md")
      discard copyFirstExisting(copyRoots, LicenseCandidates, destDir / "LICENSE")

    resolvedRev = inferResolvedRev(parser, sourceDir, effectiveRev, subtree)

    let metadata = %*{
      "name": languageName,
      "source": parser,
      "requested_rev": rev,
      "resolved_rev": resolvedRev,
      "subdir": path,
      "scanner": scannerKind,
      "queries": copiedQueries,
    }
    writeFile(destDir / "metadata.json", metadata.pretty(2))

    success = true
    echo &"installed tree-sitter parser \"{languageName}\" to {destDir}"
  finally:
    if not success and not subtreeAdded and dirExists(destDir):
      removeDir(destDir)
    if tmpDir.len > 0 and dirExists(tmpDir):
      removeDir(tmpDir)

when isMainModule:
  import cligen
  dispatch(
    installParser,
    cmdName = "install-parser",
    help = {
      "parser": "Git URL or local directory for the parser grammar.",
      "name": "Override the installed language name.",
      "path": "Subdirectory containing the grammar to copy.",
      "rev": "Optional branch, tag, or commit to check out before copying.",
      "treeSitterParsersDir": "Destination directory for installed parser assets.",
      "yes": "Automatically confirm prompts.",
      "clean": "Reinstall if the parser already exists.",
      "subtree": "Import the parser repo with git subtree instead of cloning to a temp dir.",
    },
  )
