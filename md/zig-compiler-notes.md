---
title: Zig Compiler Notes
---

# Tokenizer

Token = (tag, pos)

-   State machine
-   Token-by-token, not stored in memory

# Parser

AST Node = (tag, main_token, data)

tag = type of node main_token = index in token data = (lhs, rhs)

Example:

func decl, has:

-   func name
-   param list
-   return type
-   body, etc.

lhs == function prototype node rhs == function body

lhs, rhs points to either nodes or extra~data~ in the parser

extra~data~ == array of Index how many fields = defined by tag

for prototype it\'s 6 fields, defined as a struct: (start/end of params,
align~expr~, addrspace~expr~, section~expr~, callconv~expr~)

# Backend

1.  main.zig
    1.  buildOutputType
    2.  Compilation object created
2.  ZIR is first generated

## Compiler.zig

bin~file~: link.File

## --watch command

Sources:

1.  [Entry](https://github.com/ziglang/zig/blob/master/src/main.zig#L2844)
2.  [Update](https://github.com/ziglang/zig/blob/master/src/main.zig#L2872)
    1.  comp.makeBinFileWritable
    2.  [updateModule](https://github.com/ziglang/zig/blob/master/src/main.zig#L3103)
        1.  comp.update
