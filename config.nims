--outdir:"build"
--nimcache:"build/cache"
--define:release
--debuginfo
--linedir:on

task gen, "generate website":
  exec "nim c -r src/gen.nim"

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --privateNotes"

task publish, "generate & serve website":
  exec "rm -rf dist"
  exec "nim c -r src/gen.nim"
  exec "git subtree push --prefix dist origin gh-pages"

# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
