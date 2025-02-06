type
  MdLinkKind* = enum
    mlkPlain
    mlkImage
    
  MdNodeKind* = enum
    mnkHeader
    mnkListItem
    mnkLink
    mnkParagraph
    mnkCodeBlock
    mnkChecklist

  # MdParseCtx* = object
  #   src: string

  # StringSlice = object
  #   data: ptr char
  #   n: int

  MdNode* = object
    # ctx: ptr MdParseCtx
    # text: string
    text*: string  # TODO StringSlice
    case kind*: MdNodeKind
    of mnkHeader:
      level*: int
    of mnkListItem, mnkChecklist, mnkParagraph:
      indent*: int
    of mnkCodeBlock:
      lang*: string
    of mnkLink:
      link*: string  # TODO StringSlice
      linkKind*: MdLinkKind

iterator mdParse*(src: string): MdNode =
  template eatWhitespace = 
    i += 1
    while i < src.len and src[i] == ' ':
      i += 1

  template consumeUntil(delim: char, outStr: var string) =
    while i < src.len and src[i] != delim:
      outStr &= src[i]
      i += 1
    
  
  # TODO: parse
  var i = 0
  var text = ""
  while i < src.len:
    case src[i]
    of '[', '!':
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
    of '#':
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
    of '-', '*':
      i += 1
    else:
      # echo "hi"
      i += 1
