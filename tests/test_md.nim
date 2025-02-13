import 
  std/[strformat, sequtils],
  unittest2,
  ../src/md

suite "headers+body":
  discard

suite "codeblock":
  discard

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

