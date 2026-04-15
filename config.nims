--outdir:"build"
--nimcache:"build/cache"
--define:release
--debugger:native
--debuginfo
--linedir:on

import std/[os, sequtils, strformat, strutils]

const HighlightTheme = "zenbones"

task gen, "generate website":
  exec "nim c -r src/gen.nim --highlightTheme=" & quoteShell(HighlightTheme)

task genPriv, "generate website":
  exec "nim c -r src/gen.nim --privateNotes --highlightTheme=" & quoteShell(HighlightTheme)

task devpriv, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --privateNotes --dev --highlightTheme=" & quoteShell(HighlightTheme)

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --dev --highlightTheme=" & quoteShell(HighlightTheme)

task tsAddParser, "install a tree-sitter parser into 3rdparty/tree-sitter-parsers":
  var args = commandLineParams()
  if args.len > 0 and args[0] == "tsAddParser":
    args = args[1..^1]
  if args.len > 0 and args[0] == "--":
    args = args[1..^1]
  let extra = if args.len == 0: "" else: " " & args.mapIt(quoteShell(it)).join(" ")
  exec "nim c -r scripts/treesitter.nim" & extra

task init, "initialize to publish":
  if not dirExists("dist"):
    exec &"git worktree add -f dist gh-pages"
  exec &"git submodule update --init"

task publish, "generate & serve website":
  const dt = CompileDate & "T" & CompileTime
  exec "cd dist && git clean -fd && cd .."
  exec "nim c -r src/gen.nim --highlightTheme=" & quoteShell(HighlightTheme)
  exec &"cd dist && git add -A && git commit -m '{dt}'"
  exec "git push origin gh-pages -f && cd .."

# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
