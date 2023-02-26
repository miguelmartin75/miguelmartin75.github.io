---
title: Swift Notes
---

Links
-   [REPL implementation](https://github.com/apple/llvm-project/blob/swift/release/5.6/lldb/source/Expression/REPL.cpp)

# dynamic dispatch

One can use dynamic dispatch to override

Basically causes a vtable lookup, i.e. an indirect call - can be slow for perf critical code

# lldb

## python import lldb

``` bash
#!/bin/bash

export PYTHONPATH=/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/Resources/Python/
```

## pause a thread

<https://stackoverflow.com/a/56174578>

# FS watcher

-   <https://github.com/eonil/FSEvents>

# SwiftUI

-   declarative syntax

# Strings

-   Unicode compliant
-   value type

Conversion to C-string?

# GCD (Grand Central Dispatch)

<https://developer.apple.com/documentation/DISPATCH>

-   handles async code
-   Can specify the priority of said task. 5 main priorites.
-   Basically a thread group. A DispatchGroup is a group of tasks to
    monitor.

# Compiler Notes

## IRGen

### dynamic replacements

source: emitDynamicReplacements:
<https://github.com/apple/swift/blob/main/lib/IRGen/GenDecl.cpp#L1741:19>

how does this work?
-   https://github.com/apple/swift/blob/main/lib/IRGen/IRGenModule.h#L1149:47

Linking:
<https://github.com/apple/swift/blob/main/lib/IRGen/Linking.cpp>
