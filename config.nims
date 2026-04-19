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
  exec "nim c -r src/gen.nim --serve --port 3030 --privateNotes --dev --highlightTheme=" & quoteShell(HighlightTheme)

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3030 --dev --highlightTheme=" & quoteShell(HighlightTheme)

task init, "initialize to publish":
  if not dirExists("dist"):
    exec &"git worktree add -f dist gh-pages"
  exec &"git submodule update --init"
  exec &"nim c -r scripts/treesitter.nim -p git@github.com:alaviss/tree-sitter-nim.git -y"
  exec &"nim c -r scripts/treesitter.nim -p git@github.com:alaviss/tree-sitter-javascript.git -y"

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
