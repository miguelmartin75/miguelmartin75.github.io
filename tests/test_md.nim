import 
  std/[strformat, sequtils, sugar],
  unittest2,
  ../src/md

suite "headers+body":
  test "levels":
    let inp = &"""
# h1
## h2
### h3
#### h4
##### h5
###### h6
"""
    let 
      nodes = mdParse(inp).toSeq
      gt = collect:
        for i in 1..6:
          MdNode(
            text: &" h{i}",
            kind: mnkHeader,
            level: i,
          )
    
    check:
      nodes == gt

  test "h1 with body":
    let 
      inp = &"""
# h1
hello world.
second line
"""
      nodes = mdParse(inp).toSeq
      gt = @[
        MdNode(
          text: " h1",
          kind: mnkHeader,
          level: 1,
        ),
        MdNode(
          text: "hello world.\nsecond line",
          kind: mnkParagraph,
        )
      ]

    check:
      nodes == gt
    

suite "codeblock":
  test "paragraph -> codeblock":
      let codeInner = """
var x = 3
x += 1
"""
      let inp = &"""
This is a test
```c++
{codeInner}
```
"""
      let nodes = mdParse(inp).toSeq
      check:
        nodes == @[
          MdNode(
            text: "This is a test",
            kind: mnkParagraph,
          ),
          MdNode(
            text: codeInner,
            kind: mnkCodeBlock,
            language: "c++",
          ),
        ]
  test "codeblock -> paragraph":
      let codeInner = """
var x = 3
x += 1"""
      let inp = &"""
```c++
{codeInner}```

This is a test
"""
      let nodes = mdParse(inp).toSeq
      check:
        nodes == @[
          MdNode(
            text: codeInner,
            kind: mnkCodeBlock,
            language: "c++",
          ),
          MdNode(
            text: "This is a test",
            kind: mnkParagraph,
          ),
        ]

  test "not ending":
    for prefix in ["", "  "]:
      for lang in ["", "c++"]:
        let inp = &"""
{prefix}```{lang}
var x = 3
x += 1
"""
        let nodes = mdParse(inp).toSeq
        check:
          nodes == @[
            MdNode(
              text: inp[len(prefix)..^1],
              kind: mnkParagraph,
            )
          ]

  test "language":
    let inner = """import math
x = 3
math.ceil(x)
"""
    let inp = &"""
```python
{inner}
```
"""
    let nodes = mdParse(inp).toSeq
    check:
      nodes == @[
        MdNode(
          text: inner,
          kind: mnkCodeBlock,
          language: "python",
        )
      ]

  test "no language":
    let inp = &"""
```
a b c
```
"""
    let nodes = mdParse(inp).toSeq
    check:
      nodes == @[
        MdNode(
          text: "a b c",
          kind: mnkCodeBlock,
          language: "",
        )
      ]

suite "paragraph":
  test "basic":
    let 
      inp = &"""
hello world.
second line
"""
      nodes = mdParse(inp).toSeq
      gt = @[
        MdNode(
          text: "hello world.\nsecond line",
          kind: mnkParagraph,
        )
      ]

    check:
      nodes == gt

  test "seperate paragraph":
    let 
      inp = &"""
line.

line.
"""
      nodes = mdParse(inp).toSeq
      gt = @[
        MdNode(
          text: "line.",
          kind: mnkParagraph,
        ),
        MdNode(
          text: "\nline.",
          kind: mnkParagraph,
        )
      ]

    check:
      nodes == gt


suite "lists":
  test "nested list":
    discard

  test "multi-line item":
    discard

  test "numbered list":
    let inp = &"""
1. a
1. b) foo
"""
    let nodes = mdParse(inp).toSeq
    check:
      nodes == @[
        MdNode(
          text: " a",
          kind: mnkListItem,
          indent: 0,
          number: 1,
        ),
        MdNode(
          text: " b) foo",
          kind: mnkListItem,
          indent: 0,
          number: 2,
        ),
      ]

  test "simple bullet list":
    for prefix in ["-", "*"]:
      let inp = &"""
{prefix} a
{prefix} b) foo
{prefix} c. bar
{prefix} d
  """
      let nodes = mdParse(inp).toSeq
      check:
        nodes == @[
          MdNode(
            text: " a",
            kind: mnkListItem,
            indent: 0,
            number: -1,
          ),
          MdNode(
            text: " b) foo",
            kind: mnkListItem,
            indent: 0,
            number: -1,
          ),
          MdNode(
            text: " c. bar",
            kind: mnkListItem,
            indent: 0,
            number: -1,
          ),
          MdNode(
            text: " d",
            kind: mnkListItem,
            indent: 0,
            number: -1,
          )
        ]

