type
  MdTextStyle* = enum
    mdtsNormal
    mdtsItalics
    mdtsBold

  MdLinkKind* = enum
    mlkPlain
    mlkImage
    
  MdNodeKind* = enum
    mnkHeader
    mnkListItem
    mnkLink
    mnkParagraph
    mnkQuote  # TODO
    mnkCodeBlock
    mnkChecklist

  MdText* = object
    text*: string
    style*: MdTextStyle

  MdNode* = object
    # TODO
    # text*: seq[MdText]
    text*: string  # TODO StringSlice
    case kind*: MdNodeKind
    of mnkHeader, mnkQuote:
      level*: int
    of mnkListItem, mnkChecklist, mnkParagraph:
      indent*: int
      number*: int
    of mnkCodeBlock:
      language*: string  # TODO StringSlice
    of mnkLink:
      link*: string  # TODO StringSlice
      linkKind*: MdLinkKind

proc maybeDropLastEol*(x: string): string {.inline.} =
  if x.len > 0 and x[^1] == '\n':
    return x[0..^2]
  else:
    return x

proc `==`*(a, b: MdNode): bool =
  if a.kind == b.kind and a.text == b.text:
    case a.kind:
    of mnkHeader, mnkQuote:
      return a.level == b.level
    of mnkListItem, mnkChecklist, mnkParagraph:
      return a.indent == b.indent
    of mnkCodeBlock:
      return a.language == b.language
    of mnkLink:
      return a.link == b.link and a.linkKind == b.linkKind
  return false

iterator mdParse*(src: string): MdNode =
  var 
    i = 0
    indent = 0
    listNumber = 1
    text = ""

  template eatWhitespace = 
    i += 1
    while i < src.len and src[i] == ' ':
      i += 1

  template consumeUntil(delim: char, outStr: var string, inclDelim: bool = true) =
    while i < src.len and src[i] != delim:
      outStr &= src[i]
      i += 1
    if inclDelim and i < src.len and src[i] == delim:
      i += 1

  template handleListItem =
    # TODO: fixme
    i += 1
    consumeUntil('\n', text)
    yield MdNode(
      text: text,
      kind: mnkListItem,
      indent: indent,
      number: listNumber,
    )
    text = ""

  template maybeEndParagraph =
    if text.len > 0:
      yield MdNode(
        text: text.maybeDropLastEol,
        kind: mnkParagraph,
      )
      text = ""


  while i < src.len:
    case src[i]
    of '[', '!':  # TODO: this is incorrect ...
      var linkKind = if src[i] == '[': 
        mlkPlain
      else:
        if i + 1 < src.len:
          if src[i + 1] != '[':
            text &= src[i]
            i += 1
            continue
        i += 1
        mlkImage

      maybeEndParagraph()

      eatWhitespace()
      consumeUntil(']', text)

      var link = ""
      if i < src.len and src[i] == '(':
        i += 1
        consumeUntil(')', link)

      yield MdNode(
        text: text,
        kind: mnkLink,
        link: link,
        linkKind: linkKind,
      )
      text = ""
    of '#':
      # TODO: this is wrong
      maybeEndParagraph()

      i += 1
      var level = 1
      while i < src.len and src[i] == '#':
        level += 1
        i += 1

      consumeUntil('\n', text)
      yield MdNode(
        text: text,
        kind: mnkHeader,
        level: level,
      )
      text = ""
    of '0'..'9':
      while i < src.len and src[i] in '0'..'9':
        text &= src[i]
        i += 1

      if i < src.len and src[i] == '.':
        listNumber += 1
        text = ""
        handleListItem()
    of '-', '*':
      maybeEndParagraph()

      listNumber = -1
      text = ""
      handleListItem()
    of '`':
      var sI = i
      var c1 = 0
      while i < src.len and src[i] == '`':
        c1 += 1
        i += 1

      if c1 == 3:
        maybeEndParagraph()

        var lang = ""
        var c2 = 0
        var inLangSection = true
        while i < src.len:
          if src[i] == '`':
            c2 += 1
            if c2 == 3:
              yield MdNode(
                text: text.maybeDropLastEol,
                kind: mnkCodeBlock,
                language: lang,
              )
              text = ""
              break
          else:
            c2 = 0
            if inLangSection and src[i] == '\n':
              inLangSection = false
              i += 1
              continue

            if inLangSection:
              lang &= src[i]
            else:
              text &= src[i]
          i += 1

        if i >= src.len and c2 != 3:
          yield MdNode(
            text: src[sI..^1],
            kind: mnkParagraph,
          )
          text = ""
      else:
        while i < src.len and src[i] == '`':
          text &= '`'
          c1 -= 1
          i += 1
    of ' ':
      if text.len > 0:
        text &= src[i]
      i += 1
    of '\n':
      if text.len > 0:
        if text[^1] == '\n':
          # TODO: end paragraph, not maybe
          maybeEndParagraph()
        text &= src[i]
      i += 1
    else:
      text &= src[i]
      i += 1

  maybeEndParagraph()
