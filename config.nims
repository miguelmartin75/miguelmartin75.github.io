--outdir:"build"
--nimcache:"build/cache"
--define:release
--debuginfo
--linedir:on

import std/[strformat]

task gen, "generate website":
  exec "nim c -r src/gen.nim"

task devpriv, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --privateNotes --dev"

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --dev"

task init, "initialize to publish":
  exec &"git worktree add dist gh-pages"


task publish, "generate & serve website":
  const dt = CompileDate & "T" & CompileTime
  exec "cd dist && git clean -fd && cd .."
  exec "nim c -r src/gen.nim"
  exec &"cd dist && git add -A && git commit -m '{dt}'"
  exec "git push origin gh-pages && cd .."

# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
