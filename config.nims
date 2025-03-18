--outdir:"build"
--nimcache:"build/cache"
--define:debug

task gen, "generate website":
  exec "nim c -r src/gen.nim"

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000 --privateNotes"

task publish, "generate & serve website":
  exec "rm -rf dist"
  exec "nim c -r src/gen.nim"

# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
