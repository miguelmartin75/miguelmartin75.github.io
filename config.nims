--outdir:"build"
--nimcache:"build/cache"
--define:release

task gen, "generate website":
  exec "nim c -r src/gen.nim"

task dev, "generate & serve website":
  exec "nim c -r src/gen.nim --serve --port 3000"


# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
