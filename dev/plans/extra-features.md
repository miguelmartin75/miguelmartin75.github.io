# Extra Features Plan

## Goal

Add three markdown-rendering features to the site generator:

- a table of contents pinned on the right side of article pages
- a copy-to-clipboard button for fenced code blocks
- optional line numbers for fenced code blocks

The implementation should stay small, fit the current `md4c`-driven pipeline, and avoid JavaScript unless it is actually needed.

## Status As Of 2026-04-13

- TOC feature is not implemented yet.
- Copy-to-clipboard buttons are not implemented yet.
- Opt-in line numbers are implemented.
- Fence info parsing now supports `linenums` in `src/md4c.nim`.
- Numbered code blocks now render `pre.code-block-pre.has-line-numbers` with one `.code-line` wrapper per source line.
- `src/treesitter/highlight.nim` now renders both highlighted and plain code through the same line-aware path when `linenums` is enabled.
- `src/style.css.nimf` now provides the line-number gutter styles.
- The numbered-code CSS was adjusted so wrapping behavior lives on `.code-line-content`, not the parent `<code>`, which avoids visible gaps between numbered lines.
- `src/gen.nim` still uses the existing string-only `mdToHtml(...)` path, so TOC metadata and copy-button behavior remain future work.

## Relevant Files

- `src/gen.nim`
  - site generator entrypoint
  - builds the full HTML page in `genRoute()`
  - already injects inline JavaScript for KaTeX
  - decides how blog posts, notes, and index pages are laid out
- `src/md4c.nim`
  - Markdown-to-HTML renderer built on MD4C callbacks
  - owns heading `id` generation
  - owns fenced code block HTML emission
  - best place to collect heading metadata and extend code block markup
- `src/treesitter/highlight.nim`
  - syntax highlighter for fenced code blocks
  - currently returns a flat highlighted HTML string
  - must change if line numbers are implemented without breaking syntax highlighting
- `static/style.css`
  - global page layout and typography
  - current code block styling lives here
  - best place for sticky TOC layout, code block chrome, and line-number styling
- `md/blog/test-post.md`
  - sample post already containing a fenced code block with info string `toc`
  - useful as a fixture while implementing the TOC marker behavior

## Current Rendering Pipeline

Someone new to this codebase should start with the following flow:

1. `genRoute()` in `src/gen.nim` reads a Markdown file, splits frontmatter, calls `mdToHtml(md)`, and inserts the returned HTML into `<div class="content">`.
2. `mdToHtml()` in `src/md4c.nim` creates an `HtmlOutputState`, registers MD4C callbacks, and lets MD4C stream the document through `htmlEnterBlock()`, `htmlLeaveBlock()`, `htmlEnterSpan()`, `htmlLeaveSpan()`, and `htmlText()`.
3. Heading anchors are generated in the heading branch of `htmlLeaveBlock()`.
4. Fenced code blocks are buffered in `HtmlOutputState.codeBlockText` and emitted in the code-block branch of `htmlLeaveBlock()`.
5. Code highlighting is delegated to `highlightCode()` in `src/treesitter/highlight.nim`.
6. `highlightCode()` returns HTML that is inserted directly into `<code>...</code>`.
7. `static/style.css` styles the final HTML.

That means:

- TOC metadata belongs in `src/md4c.nim`
- page-level TOC layout belongs in `src/gen.nim` and `static/style.css`
- copy button markup belongs in `src/md4c.nim`
- copy button behavior belongs in `src/gen.nim`
- line-number-aware code HTML belongs in `src/md4c.nim` and `src/treesitter/highlight.nim`
- line number presentation belongs in `static/style.css`

## Current State

- Article pages currently render all content inside one centered `<main>` column.
- There is no page-level metadata returned from the Markdown renderer beyond the final HTML string.
- Headings already get stable `id` attributes, so the TOC does not need a second slugging pass.
- Fenced code blocks are already buffered before HTML emission, which is the correct insertion point for copy buttons and line-number options.
- Fence info parsing now supports `linenums` as an opt-in code-block option.
- Tree-sitter highlighting still produces flat HTML for normal code blocks, but `linenums` blocks now render with per-line wrappers so CSS counters can be used safely.
- A fenced code block with info string `toc` already exists in `md/blog/test-post.md`, but nothing currently gives it special behavior.
- `normalizeCodeLanguage()` already treats `toc` as a non-language fence, which makes it a good existing hook for TOC marker support.
- There is still no copy-button wrapper or clipboard script.

## Terminology

- "Fence info string" means the token string after the opening triple backticks.
- Example: for an opening fence like triple-backticks followed by `nim linenums`, the info string is `nim linenums`.
- In this plan:
  - `toc` means a fenced block with info string `toc`
  - `linenums` means an extra fence option requesting line numbers

## JavaScript Requirement Summary

### 1. Right-side TOC

- Rendering the TOC and pinning it on the right: JavaScript is not needed.
- Highlighting the current section as the reader scrolls: JavaScript is the practical choice.
- Pure CSS alternatives exist via `scroll-target-group` and `:target-current`, but they are still experimental and not reliable enough for production use.

### 2. Copy code button

- JavaScript is required.
- There is no real CSS-only or HTML-only way to trigger clipboard writes from a button.

### 3. Line numbers

- JavaScript is not needed.
- CSS counters are enough once the generated HTML includes one wrapper element per source line.

## Recommended High-Level Approach

Keep the existing renderer architecture and extend it in two places:

- extend the markdown renderer in `src/md4c.nim` so it can return metadata in addition to HTML
- extend page assembly in `src/gen.nim` so article pages can render a TOC shell and inject a small script for the features that truly need it

Recommended new types:

- `MarkdownHeading`
- `RenderedMarkdown`
- `CodeBlockOptions`

Possible shape:

```nim
type
  MarkdownHeading = object
    id: string
    level: int
    text: string

  RenderedMarkdown = object
    html: string
    headings: seq[MarkdownHeading]
    hasTocMarker: bool

  CodeBlockOptions = object
    showLineNumbers: bool
    isTocMarker: bool
```

`mdToHtml()` can either be replaced by a richer proc or kept as a thin wrapper over a new proc that returns `RenderedMarkdown`.

## Implementation Strategy By File

### `src/md4c.nim`

This is the main renderer and should own all Markdown-derived metadata.

Concrete changes:

- extend `HtmlOutputState`
- introduce `MarkdownHeading` and `RenderedMarkdown`
- add a richer render proc that returns both HTML and heading metadata
- update heading handling in `htmlLeaveBlock()` to append heading metadata
- update fenced code block handling in `htmlLeaveBlock()` to:
  - detect the `toc` info string
  - suppress normal output for TOC markers
  - emit copy-button wrappers for real code blocks
  - pass parsed code block options into the code renderer

### `src/gen.nim`

This file should stay responsible for page shell composition and small page-level scripts.

Concrete changes:

- switch article generation from `mdToHtml()` to the richer render proc
- render a two-column article shell when the page has a TOC
- render the TOC links from `RenderedMarkdown.headings`
- keep the existing inline KaTeX script and add:
  - delegated copy-button handling
  - optional TOC scrollspy behavior

### `src/treesitter/highlight.nim`

This file should stay responsible for syntax-token HTML, but it must become line-aware.

Concrete changes:

- preserve the existing capture-range logic
- refactor HTML emission so highlighted and plain code can both emit one wrapper per source line
- keep syntax span classes intact while splitting lines safely

### `static/style.css`

This file should own the final presentation.

Concrete changes:

- add article layout styles for content plus sidebar
- add sticky TOC styles
- add code block wrapper and copy-button styles
- add line-number gutter styles using CSS counters

## Local Workflow

For someone new to the repo, the main development commands are:

- `nim dev`
  - compile the generator
  - generate the site
  - serve it locally on port `3000`
- `nim gen`
  - generate the site without starting the local server

Recommended implementation workflow:

1. Start with `nim dev`.
2. Use `md/blog/test-post.md` as the first manual test fixture.
3. After each renderer change, reload the generated page and inspect the emitted HTML.
4. After each CSS change, check both desktop and narrow viewport behavior.

## Feature 1: Right-Side TOC

### Recommended Behavior

Use the existing fenced code block with info string `toc` as an opt-in marker.

Reasoning:

- the repo already contains that syntax
- it gives per-post control
- it avoids showing an empty or noisy sidebar on short posts
- it keeps the change small and direct

Recommended behavior of the marker:

- the marker does not render as a normal code block
- it enables TOC rendering for the page
- the TOC is placed in the page shell, not inline where the marker appears

### Renderer Changes

Extend `HtmlOutputState` in `src/md4c.nim` to collect headings and TOC state.

Add fields like:

- `headings: seq[MarkdownHeading]`
- `hasTocMarker: bool`

Recommended implementation steps:

1. Add the new fields to `HtmlOutputState`.
2. Add a new render proc that returns `RenderedMarkdown`.
3. In the heading branch of `htmlLeaveBlock()`:
   - keep generating the heading `id` exactly as today
   - append a `MarkdownHeading(id, level, text)` entry to `headings`
4. In the code-block branch of `htmlLeaveBlock()`:
   - inspect `codeBlockInfo`
   - if the normalized fence info is `toc`, do not emit `<pre><code>`
   - set `hasTocMarker = true`
5. Keep `mdToHtml()` as a wrapper if keeping a string-only API simplifies the rest of the repo.

Important detail:

- keep heading text extraction based on the current `headingText` accumulation logic
- continue excluding inline math/image alt text from slug generation and TOC labels unless explicitly changed later

### Generator Changes

In `src/gen.nim`, change article generation so it works from rendered markdown metadata instead of only a raw HTML string.

Current flow:

- `content = mdToHtml(md)`

Recommended flow:

- `rendered = mdToDocument(md)` or equivalent
- `content = rendered.html`
- `headings = rendered.headings`
- `showToc = rendered.hasTocMarker and headings.len > 0`

Recommended implementation steps:

1. Change only the blog-post rendering path first.
2. Leave notes, blog index, home page, RSS, and text extraction untouched.
3. Render the TOC only when `showToc` is true.
4. Keep the current blog title block and metadata inside the main content column.

Render a wider article shell around the content:

```html
<main>
  <div class="article-layout">
    <div class="article-main">
      ...
      <div class="content">...</div>
    </div>
    <aside class="toc">...</aside>
  </div>
</main>
```

TOC markup should be simple:

- `<aside class="toc">`
- `<nav aria-label="Table of contents">`
- nested or flat list of heading links

For a first pass, a flat list is enough.
Indentation can come from heading level classes:

- `toc-link level-1`
- `toc-link level-2`
- `toc-link level-3`

It is reasonable to omit very deep headings from the sidebar if needed.
Recommended initial rule:

- include `h1` through `h3`

### CSS Changes

Add article layout styles in `static/style.css`.

Recommended behavior:

- desktop: two-column layout with content on the left and TOC on the right
- mobile: single-column layout with the TOC stacked above the content or hidden behind a simple collapsible treatment later
- TOC uses `position: sticky` with a top offset

Suggested classes:

- `.article-layout`
- `.article-main`
- `.toc`
- `.toc nav`
- `.toc-link`
- `.toc-link.level-1`
- `.toc-link.level-2`
- `.toc-link.level-3`
- `.toc-link.active`

### Active Section Highlighting

If the TOC should visually follow the section currently in view, add a small JavaScript scrollspy using `IntersectionObserver`.

Recommended behavior:

- observe article headings included in the TOC
- when the leading visible heading changes, update `.active` on the matching TOC link

Recommended implementation steps:

1. Add `data-toc-link="<heading-id>"` to each TOC anchor.
2. Query all headings represented in the TOC.
3. Use a single `IntersectionObserver`.
4. Track the heading closest to the top of the viewport.
5. Remove `.active` from old links and apply it only to the current one.

This should live next to the existing inline KaTeX script in `src/gen.nim`, or in a small repo-local script if that becomes cleaner.

Do not rely on:

- `scroll-target-group`
- `:target-current`

They are still experimental and not dependable enough for the site.

## Feature 2: Copy Code Button

### Recommended Behavior

Add a small copy button to each fenced code block.

Recommended DOM shape:

```html
<div class="code-block">
  <button class="code-copy" type="button">Copy</button>
  <pre class="code-block-pre">
    <code class="language-nim">...</code>
  </pre>
</div>
```

This wrapper should be emitted directly from `MD_BLOCK_CODE` handling in `src/md4c.nim`.

### Renderer Changes

In `htmlLeaveBlock()` for `MD_BLOCK_CODE`:

- emit a wrapper around every fenced code block
- emit the button before the `<pre>`
- preserve current language classes and `data-highlighter="tree-sitter"` behavior

Recommended implementation steps:

1. Keep the existing call to `highlightCode()`.
2. Change only fenced code block output, not inline `<code>`.
3. Emit the wrapper around the existing `<pre><code>` structure.
4. Keep any language class and `data-highlighter` attributes on the `<code>` element.

The copy operation should use the rendered `<code>` element's `textContent`, not a duplicated hidden string attribute.

Reasoning:

- it avoids large attribute escaping problems
- it avoids duplicating the source code in the HTML
- pseudo-element line numbers are not part of `textContent`, so copied text stays clean

Important detail for later line-number support:

- preserve actual newline text nodes between rendered line wrappers so `textContent` still contains real newlines

### Script Changes

Add a small delegated click handler in the existing inline script block in `src/gen.nim`.

Behavior:

- listen for clicks on `.code-copy`
- find the sibling `<code>`
- call `navigator.clipboard.writeText(code.textContent ?? "")`
- briefly change the button label to `Copied` on success
- optionally show `Error` on failure

Recommended implementation steps:

1. Use one document-level click listener.
2. Detect whether the click target is inside `.code-copy`.
3. Resolve the nearest `.code-block`, then its child `<code>`.
4. Restore the button label after a short timeout.
5. Fail quietly if `navigator.clipboard` is unavailable.

Because the site is served over HTTPS on GitHub Pages, the Clipboard API should be available in the normal case.

### CSS Changes

Add styles for:

- `.code-block`
- `.code-copy`
- `.code-copy:hover`
- `.code-copy:active`
- `.code-copy.is-copied`

Recommended behavior:

- position the button in the upper-right corner of the code block
- keep it visually quiet until hover/focus if desired
- ensure it remains accessible from keyboard focus

## Feature 3: Line Numbers

### Recommended Behavior

Support line numbers as an opt-in fence option instead of enabling them globally.

Recommended fence syntax:

- a fenced code block with info string `nim linenums`
- a fenced code block with info string `python linenums`

This keeps the default output clean for prose-heavy posts and short snippets.

### Parsing Fence Options

Add a helper that parses `codeBlockInfo` into:

- normalized language
- boolean options such as `showLineNumbers`

Recommended rule:

- first token is the language
- remaining tokens are options

Example:

- `nim linenums`
- `python linenums`
- `text`
- `toc`

Suggested helper behavior:

- split the info string on whitespace
- interpret the first token as the language token, if present
- treat remaining tokens as unordered options
- ignore unknown options for now

### Renderer and Highlighter Changes

CSS counters only work cleanly if each line has a wrapper element.
The current tree-sitter highlighter does not emit those wrappers.

Do not try to post-process the final highlighted HTML with a string split on `\n`.

Reason:

- syntax highlight spans can cross line boundaries
- splitting the final HTML string would break tag structure

Instead, make line wrapping part of the code-rendering phase itself.

Recommended output shape:

```html
<pre class="code-block-pre has-line-numbers">
  <code class="language-nim">
    <span class="code-line"><span class="ts-keyword">let</span> x = 1</span>
    <span class="code-line">echo x</span>
  </code>
</pre>
```

This likely means refactoring `src/treesitter/highlight.nim` so the renderer can emit escaped and highlighted segments while also opening and closing `.code-line` wrappers at newline boundaries.

A practical approach:

- keep the existing segment calculation logic
- stream output one character range at a time
- when a segment contains newlines, split that segment at newline boundaries while preserving the currently active capture class
- open a new `.code-line` wrapper after each newline

Recommended implementation structure:

1. Introduce a small shared renderer for code blocks that understands:
   - plain escaped segments
   - highlighted segments with classes
   - line boundaries
2. Route both plain and highlighted code through that shared renderer.
3. Keep real newline characters between emitted `.code-line` elements so copied text preserves line breaks.
4. Add the line-number class only when `showLineNumbers` is true.

Plain code rendering should use the same line-wrapper path so both highlighted and non-highlighted blocks share one structure.

### CSS Changes

Use CSS counters for the line number gutter.

Suggested rules:

- `pre.has-line-numbers code { counter-reset: line; }`
- `.code-line::before { counter-increment: line; content: counter(line); }`

Recommended styling:

- fixed-width number gutter
- muted color
- right-aligned numbers
- a gap between gutter and code text
- keep wrapped long lines visually attached to the same line number

This may require:

- `.code-line { display: grid; grid-template-columns: auto 1fr; }`

or a similarly simple layout.

## Implementation Order

### 1. Add richer markdown render output [pending]

- add `MarkdownHeading`
- add `RenderedMarkdown`
- teach the renderer to collect heading metadata
- teach the renderer to detect and suppress `toc` code blocks

### 2. Add TOC page shell and styling [pending]

- update `src/gen.nim` to render the article layout
- add sticky TOC CSS
- render heading links from metadata

### 3. Add copy button wrapper and script [pending]

- wrap fenced code blocks in a `.code-block`
- add the copy button
- add the minimal clipboard script
- add button styling

### 4. Add fence option parsing [done]

- parse tokens after the language
- support `linenums`
- preserve existing language normalization behavior

### 5. Refactor code rendering for per-line wrappers [done]

- update plain code rendering
- update highlighted code rendering
- add `.code-line` wrappers
- enable CSS counters when `linenums` is set

### 6. Add TOC active-section script [pending]

- add a small `IntersectionObserver` scrollspy
- toggle `.active` on TOC links

## Validation

Verify against:

- a post with multiple `#`, `##`, and `###` headings
- a post with no `toc` marker
- a post with a `toc` marker and headings
- highlighted Nim code blocks
- non-highlighted plain text code blocks
- code blocks with and without `linenums`
- copy behavior on desktop and mobile
- narrow screens where the sticky sidebar must collapse cleanly

Regression checks:

- heading anchor links still work
- code highlighting output is unchanged apart from wrappers/classes
- copied text does not include line numbers or button text
- `toc` fences no longer render as empty code blocks

Current validation state:

- `linenums` blocks were rebuilt locally with `nim gen`.
- Highlighted and plain code blocks were checked with `linenums`.
- The numbered-line CSS was adjusted after verification to remove visible gaps between lines.
- TOC and copy-button validation are still pending because those features are not implemented yet.

## Open Decisions

These should be decided before implementation starts:

- whether the TOC should remain opt-in via the `toc` info string or become automatic for all blog posts
- whether TOC depth should stop at `h2` or `h3`
- whether line numbers should be opt-in or default-on
- whether the TOC should stack above content or be hidden entirely on mobile

## Recommended Defaults

- TOC is opt-in via the `toc` info string
- TOC includes `h1` through `h3`
- active TOC highlighting uses a small `IntersectionObserver` script
- copy buttons are enabled on all fenced code blocks
- line numbers are opt-in via `linenums`
