--outdir:"build"
--nimcache:"build/cache"

task gen, "generate website":
  setCommand "r", "src/gen.nim"
