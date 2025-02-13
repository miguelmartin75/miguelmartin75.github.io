# Package

version       = "0.1.0"
author        = "Miguel Martin"
description   = "nim static site generator"
license       = "MIT"
srcDir        = "src"
binDir        = "build"
bin           = @["nssg"]

requires "nim >= 2.0.6"
requires "unittest2"

