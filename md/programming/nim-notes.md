https://github.com/nim-lang/Nim/

# Ideas
- nim -> wasm
	- [[WAMR]] repl
	- create bindings automatically
# Compilation

## multiple output targets
- nimscript
	- staticExec to return the output of a function
- nimble downloads packages off git
- objective-c
	- how does the GC interact with obj-c's runtime?

is it possible to configure multiple output targets that interact? I think this should be
- a.nim => wasm
- b.nim => js
- c.nim => native
linking for (a, b) will happen automatically in the browser.
linking for (a, c) must happen on runtime as well, with c.nim having a WASM runtime

## embedding into a C/C++/ObjC application

- expose a C API for the application
- compile nim to a dylib that implements this C API
- link dynamically to nim at run-time

qs:
- can we reload the nim dylib
	- not sure?

how do we handle 