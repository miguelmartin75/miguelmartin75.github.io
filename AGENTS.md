# AGENTS

- Be concise in output but thorough in reasoning.
- Think before acting. Read existing files before writing code.
- Analyze code before producing a solution.
- Aim to solve root causes and provide non-hacky solutions.
- Test your code before declaring done.
- Explicit user instructions always override this file.
- No sycophantic openers or closing fluff.

## Planning

- Be decisive
    - If alternative implementation choices exist: state them and pick the recommended approach.
    - The recommended approach must be the least hacky approach (long term solutions).
- Provide necessary context to execute the plan without any prior knowledge to the code or underlying concepts
    - Do not reference the current conversation.
    - Do not answer user questions from the conversation.
- Provide references: to the codebase as codepointers (relative to the current directory)
    - The plan must enable quick onboarding to the codebase for execution.
    - Do not assume there is prior knowledge about the current codebase or terms used in the codebase.
    - If online resources were sourced: reference the URLs
- Divide the plan into phases (use the word "Phase")
    - Prioritize each phase by enabling something to work first as quickly as possible
    - Each phase should build on the previous to iteratively arrive at the end state.
- Always include success criteria.

## Simple Formatting

- No em dashes, smart quotes, or decorative Unicode symbols.
- Exception: user-observable text in frontend UIs and CLIs may use Unicode characters/codepoints when that is part of the intended experience. This exception does not apply to comments.
- Use LF (`\n`) line endings, not CRLF (`\r\n`).
- Do not use tabs for indentation.
- Natural language characters (accented letters, CJK, etc.) are fine when the content requires them.

## Writing Style

- Preserve a direct, practical, engineering-minded voice.
- Prefer plain claims over decorative prose.
- Keep writing concise, but do not remove useful technical precision.
- Preserve first-person framing when it explains motivation, experience, or judgment.
- Use questions to frame the reader's problem when that is already the post's structure.
- Prefer concrete examples, links, code, tables, formulas, and implementation details over abstract explanation.
- Examples should be realistic, not extreme or isolated in nature.
- Keep conclusions practical and outcome-focused.
- Colons are acceptable when they introduce a definition, explanation, list, or punchline. Do not remove them just to make prose more conventional.
- Avoid making posts sound like polished magazine essays. Do not add literary transitions, metaphor-heavy phrasing, or emotional language unless explicitly requested.
- Keep punchy phrasing when it is grammatically valid and clear.

## Proofreading Guidelines

- Review for grammar, clarity, and verbosity.
- Preserve the author's style by default. Suggest changes only when they improve correctness, clarity, rhythm, or concision.
- Distinguish errors from optional style preferences.
- Australian style is acceptable. Do not require Oxford commas unless they prevent ambiguity or improve readability in a specific sentence.
- Prefer direct rewrites that keep the original sentence shape where possible.
- Watch for tense mismatches, duplicated words, comma splices, missing prepositions, unclear pronouns, and overloaded sentences with too many parentheticals.
- For short philosophical posts, tighten vague references such as "this" or "it" when the referent is not obvious.
- For technical posts, preserve precision and caveats. Do not simplify away important constraints, evidence, examples, or source references.
- When suggesting punctuation changes, explain the effect on meaning or rhythm, not only the rule.
- Do not over-smooth intentionally punchy constructions if they are correct and readable.

## Code Guidelines

### Scope and Simplicity

- Keep changes small and direct.
- Prefer simple direct code and solutions over abstractions, unless clearly repeated many times (>3x).
- Avoid simple helpers that perform little to no computation, unless it is used frequently and provides readability.
- Prefer the simpler language feature, use the features in order of: `proc`, `iterator`, `converter`, `template`, `macro`.
- Only use a more complex language construct (`converter`, `template`, or `macro`) when it is necessary for performance, provides LOC reduction (or will in the near future), or has other quantifiable improvements.
    - For example, templates or macros can be used if code generation is intentionally performed to reduce LOC or for code clarity reasons

### Declaration Order

- Use this file order: imports, types, global variables (`const`, `let`, `var`), proc decls (if needed), simple inline-able procs (one line), macros, templates, procs.
- Topologically sort proc, template and macro implementations.
- If procs are mutually recursive, add proc decls (avoid this, if possible).
- If a macro or template needs a proc before its full proc implementation to respect file order, add a proc decl.
- Use local imports only when the module is used only there, e.g. `cligen` inside `when isMainModule`.

```nim
# Do
proc defaultCodeBlockOutput(dst: var string, code: string)  # before type
proc routePath(name: string): string  # before template
proc isEven(n: int): bool  # mutual recursion
proc isOdd(n: int): bool

type
  HtmlOutputOptions = object
    codeBlock: proc(dst: var string, code: string) = defaultCodeBlockOutput

proc normalizeSlug(slug: string): string {.inline.} = slug.toLowerAscii

template routeLink(name: string): string =
  "<a href=\"" & routePath(name) & "\">" & name & "</a>"

proc defaultCodeBlockOutput(dst: var string, code: string) =
  dst.add(code)

proc routePath(name: string): string =
  result = "/" & normalizeSlug(name)

proc isEven(n: int): bool =
  if n == 0:
    result = true
  else:
    result = isOdd(n - 1)

proc isOdd(n: int): bool =
  if n == 0:
    result = false
  else:
    result = isEven(n - 1)

when isMainModule:
  import cligen
  dispatch(run)

# Don't
import cligen  # keep local, used once

type
  HtmlOutputOptions = object  # missing proc decl above
    codeBlock: proc(dst: var string, code: string) = defaultCodeBlockOutput

proc normalizeSlug(slug: string): string  # unneeded decl

template routeLink(name: string): string =
  "<a href=\"" & routePath(name) & "\">" & name & "</a>"

proc defaultCodeBlockOutput(dst: var string, code: string) =
  dst.add(code)

proc routePath(name: string): string =
  result = "/" & normalizeSlug(name)

proc normalizeSlug(slug: string): string {.inline.} = slug.toLowerAscii

proc isEven(n: int): bool =  # needs proc decls
  if n == 0:
    result = true
  else:
    result = isOdd(n - 1)

proc isOdd(n: int): bool =
  if n == 0:
    result = false
  else:
    result = isEven(n - 1)

when isMainModule:
  dispatch(run)
```

### Dependencies and Comments

- Do not add third-party dependencies unless they solve the problem directly.
- Prefer the standard library over third-party dependencies unless there is a clear justification, such as measurable performance benefits, explicit instructions, or existing use in the same file.
- Keep comments brief and only where they add real clarity.

### Returns and Control Flow

- Do not use expression returns, unless the proc body is a single-line return expression.
- Prefer building `result` over using `return` when control-flow behavior is not needed.
- If a proc builds `result` by assigning to or mutating `result`, do not `return result`; let the proc reach the end naturally.
- In procs that do not build `result`, direct `return` statements are fine.
- Use early `return` only for intentional early exit that avoids unnecessary work. This includes guard clauses for invalid, empty, or nil input, and cases such as a linear scan returning once a match is found, i.e. acting as a `break` and early exit.
- Do not use `return` as a substitute for explicit branching. When enumerating cases, prefer `if`/`elif`/`else` or `case` so the alternatives remain structurally visible.
- In particular, avoid `if cond: ...; return x` followed by fallthrough code that is logically the `else` branch. Write the `else` branch explicitly instead.

```nim
# Do
proc normalizeName(name: string): string =
  result = name.strip()
  if result.len > 0:
    result[0] = result[0].toUpperAscii()

proc firstToken(data: string): string =
  let parts = data.splitWhitespace()
  if parts.len == 0:
    return
  result = parts[0]

proc classify(value: int): string =
  if value < 0:
    result = "neg"
  else:
    result = "pos"

items.sort(proc(a, b: Item): int =
  if a.rank != b.rank:
    return cmp(a.rank, b.rank)
  return cmp(a.name, b.name)
)

# Don't
proc normalizeName(name: string): string =
  result = name.strip()
  return result

proc classify(value: int): string =
  if value < 0:
    return "neg"
  result = "pos"

items.sort(proc(a, b: Item): int =
  result = cmp(a.rank, b.rank)
  if result == 0:
    result = cmp(a.name, b.name)
  return result
)
```

### Data Shapes

- Prefer objects for stable structured data, such as values that:
  - are stored or passed around as a named concept,
  - cross module or API boundaries,
  - have multiple independent call sites where naming a type would provide clarity
- Tuples are preferred for:
  - unnamed types,
  - local temporary values,
  - return values that are immediately unpacked,
  - return values used only locally at a small number of nearby call sites.
- For code style clean-ups:
    - Do not convert a proc result from `tuple[...]` to an object just for style clean-up if the tuple is immediately unpacked by the caller.
    - Do not replace a tuple with an object when the tuple is short-lived.
    - When in doubt, keep the tuple.

```nim
# Do
proc splitMdAndYaml(data: string): tuple[md: string, yaml: SimpleYaml] =
  result.md = data
  result.yaml = SimpleYaml()

let (md, yaml) = splitMdAndYaml(src)

type
  RouteInfo = object
    title: string
    dt: DateTime
    uri: string

routes.sort(proc(a, b: RouteInfo): int =
  result = cmp(a.dt, b.dt)
)
for route in routes:
  echo route.title, " -> ", route.uri

# Don't
type
  ParsedMarkdown = object
    md: string
    yaml: SimpleYaml

proc splitMdAndYaml(data: string): ParsedMarkdown =
  result.md = data
  result.yaml = SimpleYaml()

tupleRoutes.sort(proc(a, b: (string, DateTime, string)): int =
  result = cmp(a[1], b[1])
)
for route in tupleRoutes:
  echo route[0], " -> ", route[2]
```

### Naming

- General casing and word-choice rules:
  - Nim API wrappers should prefer Nim-style naming conventions.
  - Use `UpperCamelCase` for types.
  - Use `lowerCamelCase` for other identifiers such as `var`, `let`, `proc`, `template`, and `macro`.
  - Global constants should use `UpperCamelCase`.
  - Treat acronyms like normal words, e.g. `parseUrl` and `checkHttpHeader`, not `parseURL` or `checkHTTPHeader`.
  - Prefer standard abbreviations such as `dir`, `msg`, `arg`, `param`, `ident`, `indent`, `cfg`, `exe`, `ext`, `sep`, `rect`, `coord`, `sym`, `lit`, `str`, `cap`, and `mem`.
  - Prefer `subjectVerb` names, e.g. `fileExists`, not `existsFile`.
- Public API guidance:
  - Prefer exporting top-level declarations with `*` when they are part of a module's intended public API. Keep implementation details and internal helpers unexported.
- Type-family and exception naming:
  - For related value, ref, and ptr forms of the same type, use `Obj`, `Ref`, and `Ptr` suffixes.
  - Exception types should end in `Error` or `Defect`.
- Common API verb conventions:
  - Prefer direct object construction when it keeps the code simple. If complex construction logic is needed, use `initFoo` for value initialization and `newFoo` for ref initialization.
  - Use `find` for returning a position and `contains` for returning a bool.
  - Prefer `add` over `append`.
  - Use `cmp` for three-way comparison.
  - If both in-place and copy-returning forms exist, use pairs such as `reverse` / `reversed`, `sort` / `sorted`, and `rotate` / `rotated`.
- Enum rules:
  - Unless marked with the `{.pure.}` pragma, enum members should use `lowerCamelCase` with an identifying prefix, usually an abbreviation of the enum's name, e.g. `pcDir` for `PathComponent`.
  - `{.pure.}` enum members should use `UpperCamelCase` and do not need the identifying prefix.
- Accessor rules:
  - Prefer direct field access over trivial getters and setters when that keeps the API simple.
  - If a getter or setter is needed, prefer `foo` and `foo=` for cheap, side-effect-free accessors, and use `getFoo` and `setFoo` when the operation has side effects, is not `O(1)`, or is otherwise more than simple field access.

```nim
# Do
proc parseUrl(url: string): Url
proc checkHttpHeader(header: string): bool
proc fileExists(path: string): bool
proc addRoute(routes: var seq[Route], route: Route)
proc initRoute(title: string): Route
proc newRoute(title: string): ref Route

# Don't
proc parseURL(url: string): Url
proc checkHTTPHeader(header: string): bool
proc existsFile(path: string): bool
proc appendRoute(routes: var seq[Route], route: Route)
proc createRoute(title: string): Route
```

### Formatting

- Use 2 spaces for indentation; do not use tabs.
- Range operators should be written without spaces, e.g. `a..b`, `a..<b`, `a..^b`, except when the right-hand side starts with an operator, e.g. `a .. -3`.
- For multiline triple-quoted string literals, start the content on the next line.

```nim
# Do
let xs = data[0..<count]
let tail = data[i .. -3]
let msg = """
hello
world
"""

# Don't
let xs = data[0 ..< count]
let msg = """hello
world
"""
```
