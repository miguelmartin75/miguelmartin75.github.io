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

suite "codeblock":
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
{inner}```
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
          text: "a b c\n",
          kind: mnkCodeBlock,
          language: "",
        )
      ]

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

