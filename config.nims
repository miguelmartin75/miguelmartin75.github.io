--outdir:"build"
--nimcache:"build/cache"

task gen, "generate website":
  setCommand "r", "src/gen.nim"
# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
