---
title: LLVM ORC Notes
---

[[Compilers]]

# Code

## [Design Overview](https://llvm.org/docs/ORCv2.html#design-overview)

-   emulates linking and symbol resolution resolution
-   allows ORC to jit arbitary LLVM IR

## [ExecutionEngine](https://github.com/llvm/llvm-project/blob/09c2b7c35af8c4bad39f03e9f60df8bd07323028/llvm/include/llvm/ExecutionEngine/ExecutionEngine.h)

<https://llvm.org/docs/ORCv2.html#how-to-add-process-and-library-symbols-to-jitdylibs>

# Experiments

## Running Program as a REPL

Design:

-   Aim to execute code arbitrarily in running process, with access to
    memory, etc.
-   Shared API for memory

Other thoughts:

-   We could probably

### Compile to LLVM IR with clang

1.  Code
    /Users/miguelmartin/repos/langdev/repl-tests
    -   [ ] main program
    -   [ ] shared api
        -   shared api to hold state defns
    -   [ ] repl api
        -   given a string =\> execute it in the main process

2.  Commands to Execute

# Tutorial

<https://llvm.org/docs/ORCv2.html>

## Chapter 1

<https://llvm.org/docs/tutorial/BuildingAJIT1.html>

Bare bones JIT API has just two functions:

1.  addModule(Unique\<Module\>)
    -   makes the given IR module available for execution
2.  Expected\<JITEvaluatedSymbol\> lookup()
    -   searches for pointers to symbols

KaleidoscopeJIT class has the following members:

1.  ExecutionSession (ES)
    -   context for running JIT\'d code, includes a:
        -   string pool, global mutex and error reporting
2.  RTDyldObjectLinkingLayer (ObjectLayer)
    -   Can be used to add object files to the JIT
    -   Not used directly
3.  IRCompileLayer (CompileLayer)
    -   Add LLVM modules to the JIT
4.  DataLayout (DL)
5.  MangleAndInterner (Mangle)
    -   symbol and mangle layout
6.  ThreadSafeContext (Ctx)
    1.  Used when building IR files

JITTargetMachineBuilder, used by DataLayout & IRCompileLayer

# Talks

## [2018 Meeting](https://www.youtube.com/watch?v=MOQG5vkh9J8&t=1433s)

Implementing LLJit

Construct:

-   ExecutionSession, contains:
    -   String pool
    -   Session mutex
    -   Error reporting
-   RTDylibObjectLinkingLayer
    -   adds object files to JITDylib
-   ConcurrentIRCompiler
    -   Compiles LLVM IR to asm
-   For lazy:
    -   ComplieOnDemandLayer
-   For multi-threaded:
    -   ES.setDispatchMaterialization
        -   \<insert code to execute on a thread pool / seperate
            thread\>

Layers wrap compilers MaterializationUnits wrap program representations
MaterializationResponsibility tracks compiler responsibilities

## [2021 ORCv2](https://www.youtube.com/watch?v=i-inxFudrgI)

JITLink

-   LinkGraph
    1.  object file
    2.  LinkGraph builder
    3.  LinkGraph
    4.  JITLinker
    5.  Linking Context
        1.  ****Pass pipeline modification****
        2.  Add passes, any callable of Error(LinkGraph& G)
        3.  Phases:
            -   pre-prune
                -   mark elements alive before dead-stripping
            -   post-prune
                -   add/remove content (GOT, PLT entries). Global Offset
                    Table entries, Procedure Linkage Table entries
            -   post-alloc
                -   respond to assinged addressed for defined symbols
                -   use-cases: internal book-keeping
            -   pre-fixup
                -   access final addresses, e.g. for instruction
                    optimization
            -   post-fixup
                -   react to linked content after fixups have been
                    applied

```
Error interpoFunctions(LinkGraph& G) {
  for(auto *B: G.blocks()) {
	for(auto& E : B->edges()) {
	  E.setTarget(getStubeFor(E.getTarget()));
	}
  }
  return Error::success();
}
```

Can do many things:

-   Instruction stream optimization
-   Redirect calls and branches
-   Insert instrumentation
