import std/[sets, strformat, strutils]

{.passC: "-I3rdparty/md4c/src".}
{.compile: "3rdparty/md4c/src/md4c.c".}

const
  MdFlagCollapseWhitespace*          : cuint = 0x0001
  MdFlagPermissiveAtxHeaders*        : cuint = 0x0002
  MdFlagPermissiveUrlAutolinks*      : cuint = 0x0004
  MdFlagPermissiveEmailAutolinks*    : cuint = 0x0008
  MdFlagNoIndentedCodeBlocks*        : cuint = 0x0010
  MdFlagNoHtmlBlocks*                : cuint = 0x0020
  MdFlagNoHtmlSpans*                 : cuint = 0x0040
  MdFlagTables*                      : cuint = 0x0100
  MdFlagStrikethrough*               : cuint = 0x0200
  MdFlagPermissiveWwwAutolinks*      : cuint = 0x0400
  MdFlagTaskLists*                   : cuint = 0x0800
  MdFlagLatexMathSpans*              : cuint = 0x1000
  MdFlagWikiLinks*                   : cuint = 0x2000
  MdFlagUnderline*                   : cuint = 0x4000
  MdFlagHardSoftBreaks*              : cuint = 0x8000
  MdFlagPermissiveAutolinks*         : cuint = (MdFlagPermissiveEmailAutolinks or MdFlagPermissiveUrlAutolinks or MdFlagPermissiveWwwAutolinks)
  MdFlagNoHtml*                      : cuint = (MdFlagNoHtmlBlocks or MdFlagNoHtmlSpans)
  MdDialectCommonMark*               : cuint = 0
  MdDialectGithub*                   : cuint = (MdFlagPermissiveAutolinks or MdFlagTables or MdFlagStrikethrough or MdFlagTaskLists)

  MdHtmlFlagDebug*                  : cuint = 0x0001
  MdHtmlFlagVerbatimEntities*       : cuint = 0x0002
  MdHtmlFlagSkipUtf8Bom*            : cuint = 0x0004
  MdHtmlFlagXhtml*                  : cuint = 0x0008

  MdBlockDoc* = 0.cint
  MdBlockQuote* = 1.cint
  MdBlockUl* = 2.cint
  MdBlockOl* = 3.cint
  MdBlockLi* = 4.cint
  MdBlockHr* = 5.cint
  MdBlockH* = 6.cint
  MdBlockCode* = 7.cint
  MdBlockHtml* = 8.cint
  MdBlockP* = 9.cint
  MdBlockTable* = 10.cint
  MdBlockThead* = 11.cint
  MdBlockTbody* = 12.cint
  MdBlockTr* = 13.cint
  MdBlockTh* = 14.cint
  MdBlockTd* = 15.cint

  MdSpanEm* = 0.cint
  MdSpanStrong* = 1.cint
  MdSpanA* = 2.cint
  MdSpanImg* = 3.cint
  MdSpanCode* = 4.cint
  MdSpanDel* = 5.cint
  MdSpanLatexMath* = 6.cint
  MdSpanLatexMathDisplay* = 7.cint
  MdSpanWikiLink* = 8.cint
  MdSpanU* = 9.cint

  MdTextNormal* = 0.cint
  MdTextNullChar* = 1.cint
  MdTextBr* = 2.cint
  MdTextSoftBr* = 3.cint
  MdTextEntity* = 4.cint
  MdTextCode* = 5.cint
  MdTextHtml* = 6.cint
  MdTextLatexMath* = 7.cint

  MdAlignDefault* = 0.cint
  MdAlignLeft* = 1.cint
  MdAlignCenter* = 2.cint
  MdAlignRight* = 3.cint

  DefaultParserFlags* = (
    MdFlagTaskLists or
    MdFlagUnderline or
    MdFlagLatexMathSpans or
    MdDialectGithub or
    MdFlagNoIndentedCodeBlocks
  )

type
  Str8* = object
    data: cstring
    len: int

  MarkdownHeading* = object
    id*: string
    level*: int
    text*: string

  RenderedMarkdown* = object
    html*: string
    headings*: seq[MarkdownHeading]
    hasTocMarker*: bool
    hasContentBeforeFirstHeading*: bool

  MdAttribute* {.bycopy.} = object
    text*: cstring
    size*: cuint
    substrTypes*: ptr cint
    substrOffsets*: ptr cuint

  HtmlOutputPhase* = enum
    hopEnter
    hopLeave

  CodeBlockOptions* = object
    language*: string
    showLineNumbers*: bool

  CodeBlockOutput* = proc(dst: var string, code: Str8, options: CodeBlockOptions)
  MathOutput* = proc(dst: var string, display: bool, phase: HtmlOutputPhase)
  TaskOutput* = proc(dst: var string, checked: bool, phase: HtmlOutputPhase)
  WikiOutput* = proc(dst: var string, target: MdAttribute, phase: HtmlOutputPhase)

proc plainCodeBlockOutput*(dst: var string, code: Str8, options: CodeBlockOptions)
proc parseCodeBlockOptions*(lang, info: Str8): CodeBlockOptions
proc codeLanguage*(lang, info: Str8): string
proc addAttrText(dst: var string, attr: MdAttribute, escapeUrl: bool)
proc defaultMathOutput*(dst: var string, display: bool, phase: HtmlOutputPhase)
proc defaultTaskOutput*(dst: var string, checked: bool, phase: HtmlOutputPhase)
proc defaultWikiOutput*(dst: var string, target: MdAttribute, phase: HtmlOutputPhase)

type
  HtmlOutputOptions* = object
    codeBlock*: CodeBlockOutput = plainCodeBlockOutput
    math*: MathOutput = defaultMathOutput
    task*: TaskOutput = defaultTaskOutput
    wiki*: WikiOutput = defaultWikiOutput

  MdBlockOlDetail {.bycopy.} = object
    start*: cuint
    isTight*: cint
    markDelimiter*: char

  MdBlockLiDetail {.bycopy.} = object
    isTask*: cint
    taskMark*: char
    taskMarkOffset*: cuint

  MdBlockHDetail {.bycopy.} = object
    level*: cuint

  MdBlockCodeDetail {.bycopy.} = object
    info*: MdAttribute
    lang*: MdAttribute
    fenceChar*: char

  MdBlockTdDetail {.bycopy.} = object
    align*: cint

  MdSpanADetail {.bycopy.} = object
    href*: MdAttribute
    title*: MdAttribute
    isAutolink*: cint

  MdSpanImgDetail {.bycopy.} = object
    src*: MdAttribute
    title*: MdAttribute

  MdSpanWikilinkDetail {.bycopy.} = object
    target*: MdAttribute

  EnterBlockCallback = proc(blockType: cint, detail: pointer, userdata: pointer): cint {.cdecl.}
  LeaveBlockCallback = proc(blockType: cint, detail: pointer, userdata: pointer): cint {.cdecl.}
  EnterSpanCallback = proc(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.}
  LeaveSpanCallback = proc(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.}
  TextCallback = proc(textType: cint, text: cstring, size: cuint, userdata: pointer): cint {.cdecl.}
  DebugLogCallback = proc(msg: cstring, userdata: pointer) {.cdecl.}
  SyntaxCallback = proc() {.cdecl.}

  MdParser {.bycopy.} = object
    abiVersion: cuint
    flags: cuint
    enterBlock: EnterBlockCallback
    leaveBlock: LeaveBlockCallback
    enterSpan: EnterSpanCallback
    leaveSpan: LeaveSpanCallback
    text: TextCallback
    debugLog: DebugLogCallback
    syntax: SyntaxCallback

  HtmlOutputState = object
    output: ptr string
    current: ptr string
    temp: string
    rendererFlags: cuint
    outputOptions: HtmlOutputOptions
    imageNestingLevel: int
    assignedHeadingIds: HashSet[string]
    headings: seq[MarkdownHeading]
    hasTocMarker: bool
    hasContentBeforeFirstHeading: bool
    headingLevel: int
    headingText: string
    headingMathDepth: int
    inCodeBlock: bool
    codeBlockInfo: Str8
    codeBlockLang: Str8
    codeBlockText: string

  TextOutputState = object
    output: ptr string
    imageNestingLevel: int
    inHtmlTag: bool

proc mdToDocument*(
  data: string,
  parserFlags: cuint = DefaultParserFlags,
  rendererFlags: cuint = 0,
  outputOptions: HtmlOutputOptions = HtmlOutputOptions(),
): RenderedMarkdown

proc `$`*(x: Str8): string {.inline.} =
  result.setLen(x.len)
  for i in 0..<x.len:
    result[i] = x.data[i]

proc toStr8(data: string): Str8 {.inline.} =
  result.len = data.len
  result.data = cstring("")
  if data.len > 0:
    result.data = data.cstring

proc toStr8(attr: MdAttribute): Str8 {.inline.} =
  if not attr.text.isNil:
    result = Str8(data: attr.text, len: attr.size.int)

proc mdParse(
  text: ptr char,
  size: cuint,
  parser: ptr MdParser,
  userdata: pointer,
): cint {.cdecl, importc: "md_parse", header: "md4c.h".}

proc `[]`(chunk: Str8, i: int): char {.inline.} =
  chunk.data[i]

proc addHtmlEscaped*[T](dst: var string, chunk: T, start = 0, stop = -1) =
  let last = if stop < 0: chunk.len else: min(stop, chunk.len)
  for i in start..<last:
    case chunk[i]
    of '&':
      dst.add("&amp;")
    of '<':
      dst.add("&lt;")
    of '>':
      dst.add("&gt;")
    of '"':
      dst.add("&quot;")
    of '\'':
      dst.add("&apos;")
    else:
      dst.add(chunk[i])

proc isAsciiWhitespace(ch: char): bool {.inline.} =
  ch in {' ', '\t', '\n', '\r', '\f', '\v'}

proc slice(data: Str8, start, len: int): Str8 {.inline.} =
  if len <= 0 or data.data.isNil:
    return Str8()

  result.len = len
  result.data = cast[cstring](cast[int](data.data) + start)

proc stripStr8(data: Str8): Str8 =
  var
    start = 0
    stop = data.len

  while start < stop and data.data[start].isAsciiWhitespace:
    inc start
  while stop > start and data.data[stop - 1].isAsciiWhitespace:
    dec stop

  result = data.slice(start, stop - start)

proc firstToken(data: Str8): Str8 =
  let stripped = data.stripStr8()
  var stop = 0
  while stop < stripped.len and not stripped.data[stop].isAsciiWhitespace:
    inc stop
  result = stripped.slice(0, stop)

proc codeLanguage*(lang, info: Str8): string =
  var language = lang.stripStr8()
  if language.len == 0:
    language = info.firstToken()
  if language.len == 0:
    return

  result = newStringOfCap(language.len)
  for i in 0..<language.len:
    result.add(language.data[i].toLowerAscii)

proc parseCodeBlockOptions*(lang, info: Str8): CodeBlockOptions =
  result.language = codeLanguage(lang, info)

  let tokens = ($info.stripStr8()).splitWhitespace()
  for i in 1..<tokens.len:
    case tokens[i].toLowerAscii
    of "linenums":
      result.showLineNumbers = true
    else:
      discard

proc plainCodeBlockOutput*(dst: var string, code: Str8, options: CodeBlockOptions) =
  dst.add("<pre")
  if options.showLineNumbers:
    dst.add(" class=\"code-block-pre has-line-numbers\"")
  else:
    dst.add(" class=\"code-block-pre\"")
  dst.add("><code")
  if options.language.len > 0:
    dst.add(" class=\"language-")
    dst.add(options.language)
    dst.add("\"")
  dst.add(">")
  if options.showLineNumbers:
    let source = $code
    dst.add("<span class=\"code-line\"><span class=\"code-line-content\">")
    var hasOpenLine = true
    if source.len > 0:
      var start = 0
      for i, ch in source:
        if ch == '\n':
          dst.addHtmlEscaped(source, start, i)
          dst.add("</span></span>\n")
          hasOpenLine = false
          if i + 1 < source.len:
            dst.add("<span class=\"code-line\"><span class=\"code-line-content\">")
            hasOpenLine = true
          start = i + 1
      dst.addHtmlEscaped(source, start, source.len)
    if hasOpenLine:
      dst.add("</span></span>")
  else:
    dst.addHtmlEscaped(code)
  dst.add("</code></pre>\n")

proc defaultMathOutput*(dst: var string, display: bool, phase: HtmlOutputPhase) =
  case phase
  of hopEnter:
    if display:
      dst.add("<x-equation type=\"display\">")
    else:
      dst.add("<x-equation>")
  of hopLeave:
    dst.add("</x-equation>")

proc defaultTaskOutput*(dst: var string, checked: bool, phase: HtmlOutputPhase) =
  case phase
  of hopEnter:
    dst.add("<li class=\"task-list-item\"><input type=\"checkbox\" class=\"task-list-item-checkbox\" disabled")
    if checked:
      dst.add(" checked")
    dst.add(">")
  of hopLeave:
    dst.add("</li>\n")

proc defaultWikiOutput*(dst: var string, target: MdAttribute, phase: HtmlOutputPhase) =
  case phase
  of hopEnter:
    dst.add("<x-wikilink data-target=\"")
    addAttrText(dst, target, escapeUrl = false)
    dst.add("\">")
  of hopLeave:
    dst.add("</x-wikilink>")

proc taskChecked(detail: MdBlockLiDetail): bool {.inline.} =
  detail.taskMark in {'x', 'X'}

proc addUrlEscaped(dst: var string, chunk: Str8) =
  const urlExtra = {'~', '-', '_', '.', '+', '!', '*', '(', ')', ',', '%', '#', '@', '?', '=', ';', ':', '/', '$'}
  const hex = "0123456789ABCDEF"

  for i in 0..<chunk.len:
    let ch = chunk.data[i]
    if ch in {'a'..'z', 'A'..'Z', '0'..'9'} or ch in urlExtra:
      dst.add(ch)
    elif ch == '&':
      dst.add("&amp;")
    else:
      dst.add('%')
      dst.add(hex[(ord(ch) shr 4) and 0xF])
      dst.add(hex[ord(ch) and 0xF])

proc addAttrText(dst: var string, attr: MdAttribute, escapeUrl: bool) =
  if attr.text.isNil:
    return

  let
    types = cast[ptr UncheckedArray[cint]](attr.substrTypes)
    offsets = cast[ptr UncheckedArray[cuint]](attr.substrOffsets)

  if types.isNil or offsets.isNil:
    if escapeUrl:
      addUrlEscaped(dst, Str8(data: attr.text, len: attr.size.int))
    else:
      addHtmlEscaped(dst, Str8(data: attr.text, len: attr.size.int))
    return

  var i = 0
  while offsets[i] < attr.size:
    let
      start = offsets[i].int
      stop = offsets[i + 1].int
      chunk = Str8(
        data: cast[cstring](cast[int](attr.text) + start),
        len: stop - start,
      )

    case types[i]
    of MdTextNullChar:
      dst.add("\xEF\xBF\xBD")
    of MdTextEntity:
      dst.add($chunk)
    else:
      if escapeUrl:
        addUrlEscaped(dst, chunk)
      else:
        addHtmlEscaped(dst, chunk)
    inc i

proc addHeadingText(r: var HtmlOutputState, chunk: string) =
  if r.headingLevel != 0 and r.headingMathDepth == 0 and r.imageNestingLevel == 0:
    r.headingText.add(chunk)

proc addTextBoundary(r: var TextOutputState) =
  if r.output[].len == 0:
    return
  if r.output[][^1] notin {' ', '\n'}:
    r.output[].add('\n')

proc stripHtmlToText(r: var TextOutputState, chunk: Str8) =
  for i in 0..<chunk.len:
    let ch = chunk.data[i]
    if r.inHtmlTag:
      if ch == '>':
        r.inHtmlTag = false
      continue

    if ch == '<':
      r.inHtmlTag = true
      continue

    r.output[].add(ch)

proc makeHeadingId(text: string, assignedIds: var HashSet[string]): string =
  var base = newStringOfCap(text.len)
  for ch in text.toLowerAscii:
    if ch in Digits or ch in LowercaseLetters or ch in {'-', ' '}:
      base.add(ch)

  var start = 0
  while start < base.len and base[start] in Digits:
    inc start
  base = base[start..^1]
  base = base.strip(chars = {' '})
  base = base.replace(" ", "-")

  if base in assignedIds:
    stderr.writeLine &"[WARN]: {base} header is already assigned"

  result = base
  var i = 1
  while result in assignedIds or result.len == 0:
    result = base & $i
    inc i

  assignedIds.incl(result)

proc htmlEnterBlock(blockType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr HtmlOutputState](userdata)

  case blockType
  of MdBlockDoc:
    discard
  of MdBlockQuote:
    r[].current[].add("<blockquote>\n")
  of MdBlockUl:
    r[].current[].add("<ul>\n")
  of MdBlockOl:
    let detail = cast[ptr MdBlockOlDetail](detail)
    if detail[].start == 1:
      r[].current[].add("<ol>\n")
    else:
      r[].current[].add(&"<ol start=\"{detail[].start}\">\n")
  of MdBlockLi:
    let detail = cast[ptr MdBlockLiDetail](detail)
    if detail[].isTask != 0:
      r[].outputOptions.task(r[].current[], detail[].taskChecked(), hopEnter)
    else:
      r[].current[].add("<li>")
  of MdBlockHr:
    r[].current[].add(if (r[].rendererFlags and MdHtmlFlagXhtml) != 0: "<hr />\n" else: "<hr>\n")
  of MdBlockH:
    let detail = cast[ptr MdBlockHDetail](detail)
    r[].headingLevel = detail[].level.int
    r[].temp.setLen(0)
    r[].current = r[].temp.addr
    r[].headingText.setLen(0)
    r[].headingMathDepth = 0
  of MdBlockCode:
    let detail = cast[ptr MdBlockCodeDetail](detail)
    r[].inCodeBlock = true
    r[].codeBlockInfo = detail[].info.toStr8()
    r[].codeBlockLang = detail[].lang.toStr8()
    r[].codeBlockText.setLen(0)
  of MdBlockHtml:
    discard
  of MdBlockP:
    r[].current[].add("<p>")
  of MdBlockTable:
    r[].current[].add("<table>\n")
  of MdBlockThead:
    r[].current[].add("<thead>\n")
  of MdBlockTbody:
    r[].current[].add("<tbody>\n")
  of MdBlockTr:
    r[].current[].add("<tr>\n")
  of MdBlockTh:
    let detail = cast[ptr MdBlockTdDetail](detail)
    case detail[].align
    of MdAlignLeft:
      r[].current[].add("<th align=\"left\">")
    of MdAlignCenter:
      r[].current[].add("<th align=\"center\">")
    of MdAlignRight:
      r[].current[].add("<th align=\"right\">")
    else:
      r[].current[].add("<th>")
  of MdBlockTd:
    let detail = cast[ptr MdBlockTdDetail](detail)
    case detail[].align
    of MdAlignLeft:
      r[].current[].add("<td align=\"left\">")
    of MdAlignCenter:
      r[].current[].add("<td align=\"center\">")
    of MdAlignRight:
      r[].current[].add("<td align=\"right\">")
    else:
      r[].current[].add("<td>")
  else:
    discard

  return 0

proc htmlLeaveBlock(blockType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr HtmlOutputState](userdata)

  case blockType
  of MdBlockDoc:
    discard
  of MdBlockQuote:
    r[].current[].add("</blockquote>\n")
  of MdBlockUl:
    r[].current[].add("</ul>\n")
  of MdBlockOl:
    r[].current[].add("</ol>\n")
  of MdBlockLi:
    let detail = cast[ptr MdBlockLiDetail](detail)
    if detail[].isTask != 0:
      r[].outputOptions.task(r[].current[], detail[].taskChecked(), hopLeave)
    else:
      r[].current[].add("</li>\n")
  of MdBlockHr:
    discard
  of MdBlockH:
    let detail = cast[ptr MdBlockHDetail](detail)
    let level = detail[].level.int
    if r[].headings.len == 0 and r[].output[].len > 0:
      r[].hasContentBeforeFirstHeading = true
    let id = makeHeadingId(r[].headingText, r[].assignedHeadingIds)
    r[].headings.add(MarkdownHeading(
      id: id,
      level: level,
      text: r[].headingText.strip(),
    ))
    r[].current = r[].output
    r[].current[].add(&"<h{level} id=\"{id}\"><a href=\"#{id}\">")
    r[].current[].add(r[].temp)
    r[].current[].add(&"</a></h{level}>\n")
    r[].temp.setLen(0)
    r[].headingLevel = 0
    r[].headingText.setLen(0)
    r[].headingMathDepth = 0
  of MdBlockCode:
    let options = parseCodeBlockOptions(r[].codeBlockLang, r[].codeBlockInfo)
    if options.language == "toc":
      r[].hasTocMarker = true
    else:
      r[].outputOptions.codeBlock(
        r[].current[],
        r[].codeBlockText.toStr8(),
        options,
      )
    r[].inCodeBlock = false
    r[].codeBlockInfo = Str8()
    r[].codeBlockLang = Str8()
    r[].codeBlockText.setLen(0)
  of MdBlockHtml:
    discard
  of MdBlockP:
    r[].current[].add("</p>\n")
  of MdBlockTable:
    r[].current[].add("</table>\n")
  of MdBlockThead:
    r[].current[].add("</thead>\n")
  of MdBlockTbody:
    r[].current[].add("</tbody>\n")
  of MdBlockTr:
    r[].current[].add("</tr>\n")
  of MdBlockTh:
    r[].current[].add("</th>\n")
  of MdBlockTd:
    r[].current[].add("</td>\n")
  else:
    discard

  return 0

proc htmlEnterSpan(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr HtmlOutputState](userdata)
  let insideImg = r[].imageNestingLevel > 0

  if spanType == MdSpanImg:
    inc r[].imageNestingLevel
  if insideImg:
    return 0

  case spanType
  of MdSpanEm:
    r[].current[].add("<em>")
  of MdSpanStrong:
    r[].current[].add("<strong>")
  of MdSpanA:
    let detail = cast[ptr MdSpanADetail](detail)
    r[].current[].add("<a href=\"")
    addAttrText(r[].current[], detail[].href, escapeUrl = true)
    if not detail[].title.text.isNil:
      r[].current[].add("\" title=\"")
      addAttrText(r[].current[], detail[].title, escapeUrl = false)
    r[].current[].add("\">")
  of MdSpanImg:
    let detail = cast[ptr MdSpanImgDetail](detail)
    r[].current[].add("<img src=\"")
    addAttrText(r[].current[], detail[].src, escapeUrl = true)
    r[].current[].add("\" alt=\"")
  of MdSpanCode:
    r[].current[].add("<code>")
  of MdSpanDel:
    r[].current[].add("<del>")
  of MdSpanLatexMath:
    inc r[].headingMathDepth
    r[].outputOptions.math(r[].current[], false, hopEnter)
  of MdSpanLatexMathDisplay:
    inc r[].headingMathDepth
    r[].outputOptions.math(r[].current[], true, hopEnter)
  of MdSpanWikiLink:
    let detail = cast[ptr MdSpanWikilinkDetail](detail)
    r[].outputOptions.wiki(r[].current[], detail[].target, hopEnter)
  of MdSpanU:
    r[].current[].add("<u>")
  else:
    discard

  return 0

proc htmlLeaveSpan(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr HtmlOutputState](userdata)

  if spanType == MdSpanImg:
    dec r[].imageNestingLevel
  if r[].imageNestingLevel > 0:
    return 0

  case spanType
  of MdSpanEm:
    r[].current[].add("</em>")
  of MdSpanStrong:
    r[].current[].add("</strong>")
  of MdSpanA:
    r[].current[].add("</a>")
  of MdSpanImg:
    let detail = cast[ptr MdSpanImgDetail](detail)
    if not detail[].title.text.isNil:
      r[].current[].add("\" title=\"")
      addAttrText(r[].current[], detail[].title, escapeUrl = false)
    r[].current[].add(if (r[].rendererFlags and MdHtmlFlagXhtml) != 0: "\" />" else: "\">")
  of MdSpanCode:
    r[].current[].add("</code>")
  of MdSpanDel:
    r[].current[].add("</del>")
  of MdSpanLatexMath:
    dec r[].headingMathDepth
    r[].outputOptions.math(r[].current[], false, hopLeave)
  of MdSpanLatexMathDisplay:
    dec r[].headingMathDepth
    r[].outputOptions.math(r[].current[], true, hopLeave)
  of MdSpanWikiLink:
    let detail = cast[ptr MdSpanWikilinkDetail](detail)
    r[].outputOptions.wiki(r[].current[], detail[].target, hopLeave)
  of MdSpanU:
    r[].current[].add("</u>")
  else:
    discard

  return 0

proc htmlText(textType: cint, text: cstring, size: cuint, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr HtmlOutputState](userdata)
  let chunk = Str8(data: text, len: size.int)

  if r[].inCodeBlock:
    case textType
    of MdTextNullChar:
      r[].codeBlockText.add("\xEF\xBF\xBD")
    else:
      r[].codeBlockText.add($chunk)
    return 0

  case textType
  of MdTextNullChar:
    r[].current[].add("\xEF\xBF\xBD")
    r[].addHeadingText("\xEF\xBF\xBD")
  of MdTextBr:
    if r[].imageNestingLevel == 0:
      r[].current[].add(if (r[].rendererFlags and MdHtmlFlagXhtml) != 0: "<br />\n" else: "<br>\n")
    else:
      r[].current[].add(" ")
    r[].addHeadingText(" ")
  of MdTextSoftBr:
    if r[].imageNestingLevel == 0:
      r[].current[].add("\n")
    else:
      r[].current[].add(" ")
    r[].addHeadingText(" ")
  of MdTextHtml:
    r[].current[].add($chunk)
  of MdTextEntity:
    let entity = $chunk
    r[].current[].add(entity)
  else:
    addHtmlEscaped(r[].current[], chunk)
    r[].addHeadingText($chunk)

  return 0

proc htmlDebugLog(msg: cstring, userdata: pointer) {.cdecl.} =
  let r = cast[ptr HtmlOutputState](userdata)
  if (r[].rendererFlags and MdHtmlFlagDebug) != 0:
    stderr.writeLine "MD4C: " & $msg

proc textBlockBoundary(blockType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  discard detail
  var r = cast[ptr TextOutputState](userdata)
  case blockType
  of MdBlockDoc:
    discard
  else:
    r[].addTextBoundary()
  return 0

proc textEnterSpan(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  discard detail
  var r = cast[ptr TextOutputState](userdata)
  if spanType == MdSpanImg:
    inc r[].imageNestingLevel
  return 0

proc textLeaveSpan(spanType: cint, detail: pointer, userdata: pointer): cint {.cdecl.} =
  discard detail
  var r = cast[ptr TextOutputState](userdata)
  if spanType == MdSpanImg:
    dec r[].imageNestingLevel
  return 0

proc textText(textType: cint, text: cstring, size: cuint, userdata: pointer): cint {.cdecl.} =
  var r = cast[ptr TextOutputState](userdata)
  let chunk = Str8(data: text, len: size.int)

  if r[].imageNestingLevel > 0:
    return 0

  case textType
  of MdTextNullChar:
    r[].output[].add("\xEF\xBF\xBD")
  of MdTextBr, MdTextSoftBr:
    r[].addTextBoundary()
  of MdTextHtml:
    r[].stripHtmlToText(chunk)
  else:
    r[].output[].add($chunk)

  return 0

proc mdToDocument*(
  data: string,
  parserFlags: cuint = DefaultParserFlags,
  rendererFlags: cuint = 0,
  outputOptions: HtmlOutputOptions = HtmlOutputOptions(),
): RenderedMarkdown =
  if data.len != 0:
    let input =
      if (rendererFlags and MdHtmlFlagSkipUtf8Bom) != 0 and data.startsWith("\xEF\xBB\xBF"):
        data[3..^1]
      else:
        data

    if input.len != 0:
      var
        parser = MdParser(
          abiVersion: 0,
          flags: parserFlags,
          enterBlock: htmlEnterBlock,
          leaveBlock: htmlLeaveBlock,
          enterSpan: htmlEnterSpan,
          leaveSpan: htmlLeaveSpan,
          text: htmlText,
          debugLog: htmlDebugLog,
          syntax: nil,
        )
        state = HtmlOutputState(
          output: result.html.addr,
          current: result.html.addr,
          rendererFlags: rendererFlags,
          outputOptions: outputOptions,
        )

      state.assignedHeadingIds = initHashSet[string]()

      doAssert mdParse(input[0].addr, input.len.cuint, parser.addr, state.addr) == 0
      result.headings = state.headings
      result.hasTocMarker = state.hasTocMarker
      result.hasContentBeforeFirstHeading = state.hasContentBeforeFirstHeading

proc mdToHtml*(
  data: string,
  parserFlags: cuint = DefaultParserFlags,
  rendererFlags: cuint = 0,
  outputOptions: HtmlOutputOptions = HtmlOutputOptions(),
): string =
  result = mdToDocument(
    data,
    parserFlags = parserFlags,
    rendererFlags = rendererFlags,
    outputOptions = outputOptions,
  ).html

proc mdToText*(
  data: string,
  parserFlags: cuint = DefaultParserFlags,
): string =
  if data.len != 0:
    var
      parser = MdParser(
        abiVersion: 0,
        flags: parserFlags,
        enterBlock: textBlockBoundary,
        leaveBlock: textBlockBoundary,
        enterSpan: textEnterSpan,
        leaveSpan: textLeaveSpan,
        text: textText,
        debugLog: nil,
        syntax: nil,
      )
      state = TextOutputState(output: result.addr)

    doAssert mdParse(data[0].addr, data.len.cuint, parser.addr, state.addr) == 0

when isMainModule:
  let data = """
# h1 test
- [ ] a
- b

$1 + 2$

## How to Divide: $$\frac{m}{a}$$
> ### Quoted Heading
>
> quoted text

#### Sibling Heading
"""

  echo mdToHtml(data)
  echo "-----"
  echo mdToText(data)
