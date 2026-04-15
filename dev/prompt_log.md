src/gen.nim requires htmlparser due to having to run postProcessHtml and inject anchors/hrefs

Instead of depending on htmlparser, we could simplify the code by generating HTML ourselves directly from m4dc's parser. This will require the following code changes:

1. Modifying the bindings of md4c (src/m4dc.nim) 
2. Remove postProcessHtml and relevant functions in src/gen.nim by insteading using these new bindings outputting HTML directly (as a string)

---

Analyze @src/gen.nim and @src/md4c.nim and determine how to add the following features:

1. A table of contents pinned on the right hand side of the site, which follows the current 
2. Copying the text of a codeblock to the clipboard
3. Adding line numbers to a codeblock

Search online for these features if needed. Ideally JavaScript will not be needed for any of them, but determine this, but call out if it is necessary.

Document this to an implementation plan in a new file called @dev/plans/extra-features.md 

---

Analyze @src/gen.md and @src/md4c.nim 

Research ways we could support generalized syntax colors. Research online how text editors do this and how we could too. Note that treesitter syntax highlighting is supported

My best guess would be basically a map from a semantic symbol to a color, which the style.css could use source code filters that Nim supports and/or this can be a swapped out theme that is dynamically swapped out using javascript.

For the table itself, we can use a Nim object to define the schema which can be encoded/decoded with JSON (using jsony)

Document this to an implementation plan @dev/plans/config-highlight.md - write out the options
