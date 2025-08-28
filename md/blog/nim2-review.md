---
title: "A Review of Nim 2: The Good & Bad with Example Code"
state: publish
date: 2025-08-28
---

I've been using Nim for about 1-2 years now, and I believe the language is undervalued. It's not perfect, of course, but it's pleasant to write and read. My personal website [uses Nim](https://forum.nim-lang.org/t/12752#78704).

After reading a recent article on Nim (["Why Nim"](https://undefined.pyfy.ch/why-nim)) and the [associated HN comments](https://news.ycombinator.com/item?id=44931415), it's clear that comments and some information about Nim are misleading and outdated. Since Nim 2, a **tracing Garbage Collector is not the default** nor the recommended memory management option. Instead, the default memory management model is [ORC/ARC](https://nim-lang.org/docs/destructors.html), which supports C++-esque RAII with destructors, moves, and copies. When you use `ref` types, your object instances are reference-counted, similar to a `shared_ptr` in C++, but it does not include atomic counters by default (use the switch `--mm:atomicArc`, which will likely be the default in Nim 3<sup>*</sup>).

In fact, you could use Nim as a production-ready alternative to the upcoming [Carbon](https://github.com/carbon-language/carbon-lang) language. Nim has fantastic interoperability with C++, supporting templates, constructors, destructors, overloaded operators, etc. However, it does *not* compile to readable C or C++ code, which is unlike Carbon.

In this article, I review the good and bad parts of Nim 2. I'll write a tiny key/value file format that can load a user-declared object to demonstrate how some of Nim's features compose in powerful ways. Hopefully, this code example will give a good feel for the language. If you prefer to start with code, feel free to [jump to the example](#implementing-a-vector-database-in-nim) first.

I'm not going to discuss subjective dismissals of the language, such as whitespace or [case insensitivity](https://nim-lang.org/docs/manual.html#lexical-analysis-identifier-equality), which IMO are not reasons to dismiss a language.

<sup>\* The Nim team is currently working on Nim 3 (called [Nimony](https://github.com/nim-lang/nimony/)), a new iteration of the language. The largest design change is NIF, an intermediate human-readable format (similar to Lisp). NIF enables incremental compilation, a better macro system (simpler to implement), and better tooling. Here is a link to [a document describing the design](https://github.com/nim-lang/nimony/blob/master/doc/design.md) and [associated blog post](https://nim-lang.org/araq/nimony.html).</sup>

# Why Nim? The Good Parts

A common question I see online is: **What sets Nim apart?** In other words, why should you use Nim over any other language it competes with, such as C++, Go, Rust, JavaScript, or Python? In my opinion, there isn't just one unique "ground-breaking" feature or quality that sets Nim apart from the pack: it's the language as a whole. Overall, Nim is one of the most **concise**, **flexible**, and **performant** languages publicly available.

Nim is a systems programming language that feels much like a high-level scripting language like Python, as it generally requires less code to do actual work (minimal boilerplate; here's a [chatroom in 70 LOC](https://arhamjain.com/2021/11/22/nim-simple-chat.html)), i.e. it is **concise**. Nim is **flexible** as it has some of the best meta-programming capabilities and can be compiled to JavaScript (for a web [frontend](https://moigagoo.svbtle.com/exploring-karax)) or to a native executable (via C, C++, or Objective-C); it has arbitrary compile-time execution, that is: any code written in Nim can execute at compile-time. Nim can produce code that [is similar in performance](https://github.com/attractivechaos/plb2?tab=readme-ov-file#appendix-timing-on-apple-m1-macbook-pro) to other systems programming languages (C, C++, Rust, Odin, Zig). If you need to squeeze out extra performance, you can write lower-level style code, use SIMD intrinsics (e.g. using [nimsimd](https://github.com/guzba/nimsimd)) and/or generate code, e.g. [here's how to generate CUDA code at compile-time with an emit pragma](https://nim-lang.org/docs/nimc.html#gpu-compilation).

Here is an overview of *some of* Nim 2's features that make the language a joy to write in and hopefully will allow you to gain an idea of what Nim offers. This list is grouped by category from most to least commonly used:
- Again, memory management is similar to that of C++: it supports RAII with destructors, moves, copies, etc. See the [official documentation](https://nim-lang.org/docs/destructors.html). If you choose to, you manually manage memory with `defer` and `--mm:none`.
- **Compilation & Language Interoperability**:
    - Nim can compile to C, C++, Objective-C, or JavaScript. You can choose which C or C++ compiler to use, e.g. `nvcc`, `clang`, `gcc`, `tcc`, etc.
        - Because of this feature, it can import and use pre-existing code written in those languages, e.g. here are bindings for [C++'s STL](https://github.com/Clonkk/nim-cppstl) and here's [bindings to the DOM](https://nim-lang.org/docs/dom.html). Any library is an `{.importc.}`, `{.importcpp.}`, `{.importjs.}` pragma away.
        - Note, Nim's C++ interop supports templates, member functions, constructors, operators, etc. - [see importcpp's documentation](https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-importcpp-pragma).
    - Nim can be used as an alternative frontend to clang or any C/C++ compiler. Simply use the [`{.compile.}`](https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-compile-pragma) pragma in Nim sources to compile C/C++/ObjC files.
    - [NimScript](https://nim-lang.github.io/Nim/nims.html) is an interpreted version of Nim that can be used for configuring the compiler, compilation scripts and [scriptable configuration](https://github.com/beef331/nimscripter) for your Nim programs
- **Language Design**
    - procedures (`proc`) with Uniform Call Syntax (UFCS) enable [properties](https://nim-lang.org/docs/tut2.html#object-oriented-programming-properties), [method calls](https://nim-lang.org/docs/tut2.html#object-oriented-programming-method-call-syntax), [operator overloading](https://nim-lang.org/docs/tut1.html#procedures-operators). There is no need to [use macros to support OOP](https://github.com/glassesneo/OOlib) (unless you want your code to look like this), just define your types and write [procedures that operate on these types](https://nim-lang.org/docs/tut2.html#object-oriented-programming-method-call-syntax), see the [tutorial](https://nim-lang.org/docs/tut2.html#object-oriented-programming) for more information.
        - Need dynamic dispatch? Use the `method` keyword instead of `proc`
        - This is different from most languages, requiring an explicit syntax for the features UFCS supports, i.e. an explicit `class` keyword, keywords for getters/setters (`get`/`set`), operator overloading, etc.
    - `assert` and `doAssert` keywords for assert-oriented programming. `doAssert` will perform the assert in release (optimized) builds; assert will be optimized out.
    - Type system: [variants](https://nim-lang.github.io/Nim/manual.html#types-object-variants), [distinct types](https://nim-lang.github.io/Nim/manual.html#types-distinct-type), anonymous and named [tuples](https://nim-lang.github.io/Nim/manual.html#types-tuples-and-object-types) (enabling multiple, optionally named, return values), [enum bit sets](https://nim-lang.github.io/Nim/manual.html#set-type-bit-fields)
    - Generics, [type classes](https://nim-lang.github.io/Nim/manual.html#generics-type-classes) and [concepts](https://nim-lang.org/docs/manual_experimental.html#concepts) (custom type classes) are supported to constrain generic parameters.
    - Defining an iterator over a user-defined type is as simple as using the `iterator` keyword and `yield`'ing each element in your data structure using standard control flow, e.g. a `for` loop
    - procedures always contain a [result](https://nim-lang.org/docs/tut1.html#procedures-result-variable) variable, which is a nice QoL feature
     - async is supported in user-land, similar to Zig's recent direction change. Nim does this with AST transformations (with macros), e.g. `async` is implemented by transforming the [procedure into an inline iterator](https://github.com/nim-lang/Nim/blob/version-2-2/lib/pure/asyncmacro.nim#L328)
          - In Nim the async engine implementation must be defined globally, unlike Zig's new design, which is locally passed at the call site
          - There are two async engine implementations: [std/asyncdispatch](https://nim-lang.org/docs/asyncdispatch.html) and [chronos](https://github.com/status-im/nim-chronos)
          - Some prefer to not use async, due to the difficulties with debugging async code from large stack-traces. See [mummy](https://github.com/guzba/mummy) as an example for an HTTP server library opting to not use async.
- **Meta-programming**:
    - [Type relations](https://nim-lang.github.io/Nim/manual.html#type-relations) (e.g. `T is string`), which can be used in `when` statements (a compile-time `if`)
    - You can walk over the fields of a user-defined object with `T.default.fieldPairs`, which combined with procedure overloading, enables serialization to/from an arbitrary source with ease, e.g. see my code example, [jsony](https://github.com/treeform/jsony/blob/master/src/jsony.nim#L821) or [debby](https://github.com/treeform/debby/blob/master/src/debby/sqlite.nim#L319-L325)
        - With custom pragmas, you can add arbitrary metadata to fields, e.g. to mark a field as a [primary key for a database ORM](https://nim-lang.github.io/Nim/manual.html#userminusdefined-pragmas-custom-annotations), rename fields, skip certain fields, etc.
    - Arbitrary compile-time code execution. When code is written in pure Nim, it can be executed at compile-time and results can be stored in a `const` identifier, e.g. `const myFileContents = readFile("file.txt")`
    - Macros enable you to perform AST-to-AST transformations, on both an `untyped` AST (before type-checking is performed) and a `typed` AST (after type-checking is performed). With this feature you can generate a [CLI argument parser](https://github.com/c-blake/cligen/), write DSLs for languages (e.g. [HTML](https://github.com/karaxnim/karax), [GLSL](https://github.com/treeform/shady)), generate bindings for other languages, generate types at compile-time, etc.
    - Templates are a simpler form of a macro, which essentially performs a "copy and paste", similar to a C macro, but they are "hygienic". Hygienic simply means the variables in the expanded template don't pollute the current scope, unless explicitly marked to do so with `{.inject.}`. For example:
        ```nim
        template echoMs*(prefix: string, body: untyped) =
          let t1 = nowMs()  # here t1 won't be injected into the call site's scope
          body
          let
            t2 = nowMs()
            delta = t2 - t1

          var deltaStr = ""
          deltaStr.formatValue(delta, ".3f")
          echo prefix, deltaStr, "ms"

        # at a call site...
        echoMs("foo: "):  # pass in the body (a statement list) with the : operator
          foo()
        ```

# Implementing a Simple Key/Value File Format

Here's the code for the full example in the [Nim Playground](https://play.nim-lang.org/#pasty=kRhvMEVq) or as a [gist](https://gist.github.com/miguelmartin75/c41143c50c7a055d0b8b36e690a5cd56).

My favourite combination of features in Nim has to be `fieldPairs` and procedure overloading. This combination of features enables an easy way to serialize and de-serialize types to/from various sources (databases, files, a network, etc.) without requiring external code generation scripts.

To demonstrate this combination of features, I'll write a simple key/value file format. For example, say we wanted to load configuration from a text file. The schema of the file would be defined by a user-defined object, such as:

```nim
type
  Config = object
    name: string
    lr: float
    betas: seq[float]
```

Here is an associated file for the `Config` object, if using `=` as a separator for keys and values:

```text
name=my experiment
lr=0.001
betas=[0.99, 0.999]
```

To implement this, we will need to define a `load[T]` function that accepts a file path and returns a `T`. The `load` function will iterate over the fields of the type `T` and call an overloaded `proc` called `parseValue` to parse each value string. I will provide `parseValue` for some primitive types. Let's see how to implement `load`:

```nim
import std/[parseutils, strformat, strutils, tables, sugar, enumerate]

type ParseError* = object of CatchableError

proc parseValue*(x: var int, value: string): bool = parseInt(value, x) > 0
proc parseValue*(x: var float, value: string): bool = parseFloat(value, x) > 0
proc parseValue*(x: var string, value: string): bool =
  x = value
  return true

proc load*[T: object](fp: string, sep: string = "="): T =
  let
    content = readFile(fp)
    kvs = collect:
      for i, line in enumerate(content.splitLines):
        if line.len == 0:
          continue
        let kv = line.split(sep)
        if kv.len != 2:
          raise newException(ParseError,
            &"line: {i}, expected a key and value pair seperated by {sep}" &
            &"got instead {kv.len} seperations, line content: {line}"
          )
        {kv[0]: kv[1]}

  for name, value in result.fieldPairs:
    if name in kvs:
      if not parseValue(value, kvs[name]):
        raise newException(ParseError,
          "could not parse field: '" &
          $name &
          "' with specified value: " &
          kvs[name] &
          " (expected type is: " & $typeof(value) & ")"
        )
        # NOTE: the below line wont work due to how fieldPairs works (`name` & `value` are mangled)
        # raise newException(CatchableError, &"could not parse '{name}' ...")
```

If a user needs need custom parsing support for their type, they can provide more overloaded versions of `parseValue`. I'll provide an overload for `seq[T]` as the `Config` type uses a `seq[float]`.

```nim
proc parseValue*[T](xs: var seq[T], value: string): bool =
  if not value.startsWith("[") and not value.endsWith("]"):
    raise newException(ParseError, "expected seq to start and end with '[' and ']'")

  for value in value[1..^2].split(","):
    var tmp: T
    if not parseValue(tmp, value.strip(trailing=false)):
      raise newException(ParseError, &"could not parse {value} as type {$T}")
    xs.add tmp
  return true
```

Now we can load a `Config` object at runtime:
```nim
let config = load[Config]("config.txt")
echo config
```

and at compile-time, by changing `let` to `const` - nice!
```nim
const config = load[Config]("config.txt")
static:  # a static block executes each statement at compile time
  echo "Using configuration:"
  echo config
```

I'll leave handling nested types as an exercise to the reader (hint: you'll likely have to change the format a bit).

# The Bad

Using Nim is not all sunshine and rainbows. Nim's weaknesses, in my opinion, are with respect to tooling and some minor things with the compiler and language. Also, in my opinion, to get the most out of Nim, you should understand and know clang/GCC's compiler switches (or the C compiler of your choice, such as MSVC).

Here's a list of my nit-picks with Nim, they're nits as they will not block you from developing productively with the language. Feel free to correct me in the comments about any of the following points:
- **Tooling**:
  - The LSP could be faster, and it sometimes crashes due to syntax errors or produces zombie processes.
  - Debugging Nim is not fun. Names are mangled twice, once due to the Nim compiler and again due to the C or C++ compiler. Pressing tab to expand an identifier in GDB or LLDB's TUI/CLI is not ideal. Assertions (`assert`/`doAssert`), [libraries to help with fuzzing](https://github.com/status-im/nim-drchaos), and unit tests help prevent having to debug your code in the first place.
   - You can't debug NimScript.
- **Compiler and Language Design**
    - Compile times are reasonably fast, but they could be better. I've never waited >5s for a build, usually <1s, but I've been dealing with <50K LOC projects.
        - Compile times are slower than they could be because of the following reasons: no incremental build support, and no LLVM backend (or custom IR) - that is, compiling to C first has some overhead.
        - [nlvm](https://github.com/arnetheduck/nlvm) is an LLVM backend for Nim, but I haven't used it. Nim3 will have incremental builds and maybe an official LLVM backend.
    - Some language features can be confusing to newcomers. For example, iterators are by default inline iterators (due to performance benefits), but inline iterators cannot be passed around to procedures. Instead, `{.closure.}` iterators are required for this use-case, or alternatively, you must use a `template` or `macro` with inline iterators. Coming from a C++ mindset for iterators, it can be confusing.
    - You cannot forward arguments (`varargs`) to a function with some prefixed arguments *easily*, e.g. the equivalent code for this Python snippet requires you to write a macro: `foo(1, "a", *args, **kwargs)`. An `...` operator (similar to C++) could solve this, to expand the arguments inline, i.e. `foo(1, "a", args...)`.
    - Writing macros can be difficult and requires compile-time execution. In some cases, having access to the macro's API at run-time would be better, e.g. to get around the restrictions of NimScript (debugging, FFI).
      - The current solution is to import the compiler's parser API, which is a similar, but different API to a Nim macro. Nim3's NIF will solve this problem.
- **Standard Library:**
    - WASM is not supported in the standard library. You can compile to WASM with clang (with or without emscripten), but you'll need to write your own bindings as the `{.importjs.}` pragma is not supported when targeting WASM. You can [define your own `{.importjs.}` pragma equivalent](https://github.com/yglukhov/wasmrt), or do what emscripten in C/C++ land does (`EM_JS`, etc.), but it would be nice if this were supported out of the box.
    - The standard library deserves a potential redesign, due to some new language features introduced since its original conception.

# Conclusion

Overall, Nim is a great systems programming language. It's opened my eyes to what a programming language can be. You don't need to write a lot of code in Nim to do something useful, and it's pretty easy to write code that can generalize. Nim has a small community, but some libraries are really high quality. For example, if you want to write a CLI tool in the language, then check out [cligen](https://github.com/c-blake/cligen) for argument parsing. cligen is similar to [click](https://click.palletsprojects.com/en/stable/) in Python-land.

Here are some other third-party libraries I recommend checking out if you use the language, in no particular order:
- HTTP and WebSocket server: [mummy](https://github.com/guzba/mummy)
- HTML DSL and React alternative: [karax](https://github.com/karaxnim/karax)
- A nice libcurl wrapper: [curly](https://github.com/guzba/curly)
- Compression: [zippy](https://github.com/guzba/zippy)
- Fonts and vector graphics: [pixie](https://github.com/treeform/pixie)
- A tensor library: [Arraymancer](http://github.com/mratsim/Arraymancer/)
- Fast JSON serialization [jsony](https://github.com/treeform/jsony)
- CLI argument parser: [cligen](https://github.com/c-blake/cligen)
