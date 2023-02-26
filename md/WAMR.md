[WAMR](https://github.com/bytecodealliance/wasm-micro-runtime)
- iwasm is VM core
- wamrc is the AOT compiler
- Example
	- https://github.com/bytecodealliance/wasm-micro-runtime/blob/main/samples/multi-module/src/main.c#L159
	- Module
		- register module: 
		- find module: `wasm_runtime_find_module_registered`
		- unload module: 
- Dynamic patching
	- Can we dynamically patch whole modules?
	- Can we dynamically patch a function defined in a module?
	- Tests
		- Whole Module
			- Load module B depending on A
			- Run A.f()
			- Update module A
			- Run A.f()
		- Update A.f
			- Load module B depending on A
			- Run A.f()
			- Update function A.f
			- Run A.f()
		- Edge-case
			- Load module B depending on A
			- Run A.f()
			- Update function A.f
			- Run A.f()
			- Load module C depending on A
			- Run A.f() => should run updated function
- Code execution
	- Execute specific WASM code in one of the following modes:
		- Interpreted
		- Fast JIT
		- LLVM JIT
		- AOT? I don't think this is possible - putting this here to investigate
- [shared mem](https://github.com/WebAssembly/threads/blob/main/proposals/threads/Overview.md#shared-linear-memory)
	- 

# build

[docs](https://github.com/bytecodealliance/wasm-micro-runtime/blob/main/doc/build_wamr.md)

```
cmake -DWAMR_BUILD_FAST_INTERP=1 -DWAMR_BUILD_AOT=1 -DWAMR_BUILD_JIT=0 -DWAMR_BUILD_FAST_JIT=0 ..
```

fast_interp=1 vs interp=1 => 2x more memory

```
cmake -DWAMR_BUILD_FAST_INTERP=1 -DWAMR_BUILD_AOT=1 -DWAMR_BUILD_JIT=1 -DWAMR_BUILD_FAST_JIT=0 ..
```

fast jit is [asmjit](https://asmjit.com/) library - only supported on x86

# src
Memory: https://github.com/bytecodealliance/wasm-micro-runtime/blob/dd62b32b201db8e5939e1084757c712145e93264/doc/memory_tune.md

- execute fn `wasm_application_execute_func`
	- `core/iwasm/common/wasm_application.c` line 282 `execute_func`
	- $O(N*M)$ lookup function names with strcmp $M$ is the largest function string name
- find/name a module:
	- `wasm_runtime_register_module`
	- `wasm_runtime_find_module_registered`: uses a linked list, O(n) lookup

