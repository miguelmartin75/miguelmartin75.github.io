# Configurable Syntax Highlighting Plan

## Goal

Make syntax colors configurable instead of hard-coded in `style.css`, while keeping the current static-site pipeline:

- markdown is rendered at build time
- tree-sitter produces token captures at build time
- CSS controls presentation

Use Nim source code filters for stylesheet authoring, so the authored stylesheet becomes a Nim-templated source file that emits the final `style.css` at build time.

The target design is a hybrid theme model:

- raw tree-sitter capture names remain first-class theme keys
- optional aliases provide a repo-owned normalized layer
- explicit styles for raw tree-sitter capture names override alias-based styles

There is no runtime theme swapping in scope for this plan.

## Current State

- `src/md4c.nim` buffers fenced code block text and calls `highlightCode(...)` when leaving `MD_BLOCK_CODE`.
- `src/treesitter/highlight.nim` turns tree-sitter capture names into cumulative CSS classes such as:
  - `ts-function`
  - `ts-function-call`
  - `ts-keyword`
  - `ts-comment-documentation`
- `static/style.css` currently assigns colors directly to those classes.
- Nim and JavaScript/JSX are already wired up through the same tree-sitter pipeline.
- There is no theme schema, no theme files, and no generated CSS.

This means the highlighting pipeline already has the right structure:

1. tree-sitter produces capture names
2. HTML gets stable token classes
3. CSS assigns visual styles

The missing piece is a configurable theme layer between capture names and CSS output, along with a build-owned CSS generation step.

## Decision

Use a hybrid model with raw capture names plus optional aliases.

Rules:

- theme authors can define styles directly for raw tree-sitter capture names such as:
  - `function.call`
  - `comment.documentation`
  - `keyword.operator`
- the repo can also define aliases from raw captures into normalized repo-level token names such as:
  - `parameter` -> `variable.parameter`
  - `method` -> `function.method`
  - `conditional` -> `keyword.control.conditional`
  - `repeat` -> `keyword.control.repeat`
  - `include` -> `keyword.control.import`
- if a valid style exists for the raw tree-sitter capture name, that style wins first
- alias resolution is only used when there is no explicit raw-capture style

This keeps tree-sitter detail available when needed, while still allowing cross-language normalization over time.

## Theme Lookup Precedence

Theme resolution should follow this order for a capture like `function.call.special`:

1. exact raw capture name match
2. longest raw capture prefix match
3. alias target exact match
4. alias target longest dotted-prefix match
5. no match, fall back to inherited/default text color

Examples:

- For `comment.documentation`, prefer:
  1. `comment.documentation`
  2. `comment`
  3. alias target, if any
- For `conditional`, prefer:
  1. `conditional`
  2. alias target like `keyword.control.conditional`
  3. `keyword.control`
  4. `keyword`

Important constraint:

- aliases must not override an explicit raw capture style

That is the new override system.

## Why This Design

This design gives the repo three useful properties:

- exact tree-sitter query output remains directly themeable
- multiple languages can gradually share a cleaner semantic vocabulary
- the first implementation stays small because it builds on the existing `ts-*` class output

It also avoids premature taxonomy work. If a grammar already emits a useful capture name, the theme can style it directly without waiting for a canonical mapping.

## Query Guidance

When additional languages are added, keep the token queries general enough to share theme data across languages.

Rules:

- prefer upstream tree-sitter highlight queries when they already use useful capture names
- prefer standard dotted captures such as:
  - `function.method`
  - `function.builtin`
  - `variable.parameter`
  - `string.special`
  - `punctuation.special`
  - `tag`
  - `attribute`
- do not rename query captures just to fit one local theme
- use raw token styling and dotted-prefix fallback first
- add repo-owned aliases only when different grammars express the same concept with materially different raw names, such as:
  - `parameter` -> `variable.parameter`
  - `method` -> `function.method`
  - `conditional` -> `keyword.control.conditional`
  - `repeat` -> `keyword.control.repeat`
  - `include` -> `keyword.control.import`
  - `exception` -> `keyword.control.exception`

That keeps the query layer close to tree-sitter conventions and lets future languages plug into the same theme model with minimal per-language work.

## Default Theme: Zenbones

The default syntax theme should be based on the upstream `zenbones` theme from `zenbones.nvim`, using the light-background variant as the repo default.

Reasoning:

- the current site is light-themed
- Zenbones is intentionally contrast-based rather than saturation-based
- syntax is differentiated mostly through weight and italics, not bright rainbow colors
- stronger hues are used more for diagnostics and UI than for ordinary code tokens

For this repo, that means the default syntax config should preserve the same overall behavior:

- comments and strings are italic
- statements and operators are bold
- identifiers stay close to body text
- functions stay near the main foreground color
- types shift warmer/browner
- punctuation is quieter than text

This is a better default match for the site than a high-saturation editor palette.

## Theme Schema

The schema should support more than just foreground color.

At minimum, support:

- foreground color
- background color
- bold
- italic
- underline

Suggested Nim shape:

```nim
type
  SyntaxFontStyle = enum
    sfsBold
    sfsItalic
    sfsUnderline

  SyntaxStyle = object
    fg*: string
    bg*: string
    styles*: seq[SyntaxFontStyle]

  SyntaxTheme = object
    name*: string
    codeBg*: string
    codeBorder*: string
    tokens*: Table[string, SyntaxStyle]
```

There should be no separate `dev/highlight.json` or similar selector file.

Theme selection should come from:

- a CLI arg on `src/gen.nim`
- or a single repo default defined in `config.nims` and passed through by the existing tasks

Repo-owned aliases should live in Nim code, not in a separate JSON file.

Suggested alias table shape in `src/highlight_config.nim`:

```nim
let HighlightAliases = {
  "parameter": "variable.parameter",
  "method": "function.method",
  "conditional": "keyword.control.conditional",
  "repeat": "keyword.control.repeat",
  "include": "keyword.control.import",
  "exception": "keyword.control.exception",
}.toTable
```

Suggested theme JSON shape for `themes/highlight/zenbones.json`:

```json
{
  "name": "zenbones",
  "codeBg": "#EBE7E6",
  "codeBorder": "#CFC1BA",
  "tokens": {
    "comment": { "fg": "#948985", "styles": ["sfsItalic"] },
    "comment.documentation": { "fg": "#948985", "styles": ["sfsItalic"] },
    "string": { "fg": "#556570", "styles": ["sfsItalic"] },
    "string.escape": { "fg": "#4F5E68", "styles": ["sfsBold"] },
    "string.special": { "fg": "#4F5E68", "styles": ["sfsItalic"] },
    "character": { "fg": "#556570", "styles": ["sfsItalic"] },
    "number": { "fg": "#556570" },
    "float": { "fg": "#556570" },
    "boolean": { "fg": "#2C363C", "styles": ["sfsItalic"] },
    "variable": { "fg": "#44525B" },
    "variable.builtin": { "fg": "#556570", "styles": ["sfsItalic"] },
    "variable.parameter": { "fg": "#44525B" },
    "parameter": { "fg": "#44525B" },
    "field": { "fg": "#44525B" },
    "property": { "fg": "#44525B" },
    "constant": { "fg": "#44525B", "styles": ["sfsBold"] },
    "constant.builtin": { "fg": "#556570", "styles": ["sfsItalic"] },
    "function": { "fg": "#2C363C" },
    "function.builtin": { "fg": "#2C363C" },
    "function.call": { "fg": "#2C363C" },
    "function.macro": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "function.method": { "fg": "#2C363C" },
    "method": { "fg": "#2C363C" },
    "constructor": { "fg": "#4F5E68", "styles": ["sfsBold"] },
    "keyword": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.function": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.operator": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.return": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.control": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.control.conditional": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.control.repeat": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.control.import": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "keyword.control.exception": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "conditional": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "repeat": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "include": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "exception": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "type": { "fg": "#6A5549" },
    "type.builtin": { "fg": "#6A5549" },
    "type.definition": { "fg": "#6A5549" },
    "type.qualifier": { "fg": "#6A5549" },
    "tag": { "fg": "#6A5549" },
    "attribute": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "embedded": { "fg": "#4F5E68" },
    "operator": { "fg": "#2C363C", "styles": ["sfsBold"] },
    "punctuation": { "fg": "#8E817B" },
    "punctuation.delimiter": { "fg": "#8E817B" },
    "punctuation.bracket": { "fg": "#8E817B" },
    "punctuation.special": { "fg": "#8E817B" }
  }
}
```

Notes on this default mapping:

- it intentionally includes both normalized semantic keys and concrete raw capture names already produced by the repo
- it also covers the capture families already emitted by JavaScript/JSX, so the first theme works for current languages instead of only Nim
- concrete raw capture names such as `conditional`, `repeat`, `include`, and `exception` are defined explicitly so they win before alias lookup
- the alias table is still useful when languages differ, such as `parameter` vs `variable.parameter` and `method` vs `function.method`
- the chosen values come from upstream `zenbones.nvim` light-mode groups:
  - `Comment` -> `#948985`, italic
  - `String` and `Number` -> `#556570`
  - `Identifier` -> `#44525B`
  - `Function` and `Statement` -> `#2C363C`
  - `Type` -> `#6A5549`
  - `Special` -> `#4F5E68`
  - `Delimiter` -> `#8E817B`

## CSS Generation Strategy

Keep the current emitted HTML model and generate CSS rules from the theme config.

Use a Nim source code filter template for the authored stylesheet instead of concatenating plain CSS strings by hand.

Important constraint from Nim's filter model:

- source code filters preprocess Nim source before parsing
- they do not run directly on an arbitrary standalone `.css` file
- therefore the authored stylesheet should be an include-able template source such as `src/style.css.nimf` that defines a proc returning CSS text

Use `stdtmpl` for this template layer.

Suggested template shape:

```nim
#? stdtmpl(subsChar = '$', metaChar = '#')
#proc renderStyleCss(codeBg, codeBorder, tokenCss: string): string =
#  result = ""
pre > code {
  background: $codeBg;
  border: 1px solid $codeBorder;
}

$tokenCss
```

This keeps the final assembly in Nim's normal build pipeline:

- `src/highlight_config.nim` resolves the selected theme and renders token rules into `tokenCss`
- `src/gen.nim` calls the proc produced from `src/style.css.nimf`
- the returned CSS string is written to `dist/style.css`

Because the HTML already contains cumulative classes, CSS generation can stay direct:

- `function` -> `.ts-function`
- `function.call` -> `.ts-function-call`
- `comment.documentation` -> `.ts-comment-documentation`

Generated selectors should be emitted in increasing specificity order so more specific dotted names appear later.

Example:

```css
pre > code .ts-comment { color: #948985; font-style: italic; }
pre > code .ts-comment-documentation { color: #948985; font-style: italic; }
pre > code .ts-function { color: #2C363C; }
pre > code .ts-function-call { color: #2C363C; }
```

This keeps the runtime simple:

- no browser re-highlighting
- no JavaScript dependency
- no theme switching logic
- no custom CSS templating engine outside Nim's own source filter system

## File Layout

Use JSON for theme data and keep the authored stylesheet under `src/` as a Nim source-filter template, with Nim generating the final stylesheet into `dist/`.

Recommended file layout:

- `themes/highlight/<theme-name>.json`
- `src/style.css.nimf`
- `src/highlight_config.nim` or similar for config decoding and CSS generation
- `src/gen.nim`
- `config.nims`
- `dist/style.css`

Planned responsibility split:

- `src/style.css.nimf` is the authored source stylesheet template using Nim's `stdtmpl` source code filter
- `src/highlight_config.nim` loads `themes/highlight/<theme-name>.json`, owns the alias table, and generates syntax-token CSS
- `src/gen.nim` accepts a `highlightTheme` CLI arg and passes the selected theme into the stylesheet generation step
- `config.nims` can define the repo default theme once and forward it through the build tasks
- Nim includes `src/style.css.nimf`
- Nim calls the generated proc with theme values and generated syntax-token CSS
- the final result is written to `dist/style.css`
- `gen.nim` should treat `dist/style.css` as a generated asset, not a copied static file

This keeps one final stylesheet URL in the site:

- pages still link `/style.css`
- the source of truth moves from `static/style.css` to `src/style.css.nimf`

## Resolver Behavior

Add a small resolver in Nim that can answer:

- what style applies to this raw capture name
- whether that style came from a direct raw-capture key or from an alias path

Suggested resolution steps:

1. split raw capture name by `.`
2. check exact raw name, then shorter raw prefixes
3. if nothing matches, look up alias for the raw capture
4. if an alias exists, check exact alias target, then shorter alias prefixes
5. return no style if still unresolved

Suggested examples:

- raw capture `function.call`
  - direct match: `function.call`
  - fallback: `function`
- raw capture `conditional`
  - direct match: `conditional`
  - alias: `keyword.control.conditional`
  - alias fallback: `keyword.control`
  - alias fallback: `keyword`

## Implementation Plan

## Phase 1: Extract Current Styles into Config

- create `themes/highlight/zenbones.json`
- replace the handwritten `static/style.css` syntax section with an authored stylesheet template at `src/style.css.nimf`
- seed the default token config from the upstream Zenbones light theme
- include tokens already emitted by the current Nim and JavaScript/JSX queries
- add Nim types for decoding with `jsony`
- add a repo-owned alias table in `src/highlight_config.nim`
- add a `highlightTheme` CLI arg to `src/gen.nim`
- let `config.nims` provide the repo default by forwarding that arg through existing tasks
- keep non-token base code block layout styles in `src/style.css.nimf`

Result:

- syntax token styling is defined in data instead of handwritten CSS
- theme data lives only in per-theme files
- theme selection comes from CLI or `config.nims`, not from a separate JSON file
- the default theme is Zenbones-derived instead of being copied from the current ad hoc colors
- the stylesheet source of truth is now under `src/` and participates in Nim's normal compile-time source-filter flow

## Phase 2: Implement Theme Resolver

- add a resolver that handles:
  - exact raw capture matches
  - raw dotted-prefix fallback
  - alias mapping
  - alias dotted-prefix fallback
- ensure explicit raw capture styles always win over aliases

Result:

- the override system is defined in code instead of implied by CSS alone

## Phase 3: Generate CSS from the Resolved Theme Data

- add CSS generation from the configured token keys
- emit selectors for all token keys present in the chosen theme
- order selectors from least specific to most specific
- remove token-specific hard-coded rules from `src/style.css.nimf`
- generate the final `dist/style.css` by calling the proc emitted from `src/style.css.nimf`

Result:

- visual output still matches the current site
- token styles are now config-driven
- `dist/style.css` is fully generated by the build through Nim's `stdtmpl` source filter plus theme-driven token CSS

## Phase 4: Add Language Growth Support

- generalize language registration in `src/treesitter/highlight.nim` and `src/treesitter/languages.nim`
- add parsers and queries for additional languages
- prefer upstream queries and standard tree-sitter capture names when adding languages
- do not rewrite query captures just to force all languages into one repo-specific taxonomy
- add aliases only where raw captures differ enough to justify normalization

Result:

- the same theme data model can cover more than Nim and JavaScript without forcing every language into identical raw capture names

## Optional Future Work

- support `locals.scm` to improve context-aware symbol classes
- support `injections.scm` for embedded languages
- add config validation for:
  - duplicate aliases
  - alias cycles
  - invalid token keys
- add a small preview page for comparing theme output across sample snippets

## Recommendation Summary

The implementation should:

- keep raw tree-sitter capture names as first-class theme keys
- support optional aliases for normalized semantic buckets
- resolve direct raw-capture styles before alias-based styles
- store each theme in `themes/highlight/<theme-name>.json` decoded by `jsony`
- keep repo-owned aliases in Nim code instead of a separate config file
- select the theme via CLI arg, with `config.nims` optionally providing the repo default
- define the default syntax theme as the Zenbones light variant
- keep queries close to upstream tree-sitter capture names so future languages generalize cleanly
- use `src/style.css.nimf` as the authored stylesheet source via Nim's source code filter system
- generate `dist/style.css` at build time
- keep runtime theming and theme swapping out of scope

That gives a configurable system with a clear override model and minimal disruption to the current markdown and tree-sitter pipeline.
