import std/[algorithm, re, sets, strutils, tables]

import bindings
import languages
import ../md4c

type
  HighlightResult* = object
    html*: string
    highlighted*: bool
    languageClass*: string

  CaptureRange = object
    startByte: int
    endByte: int
    captureName: string
    patternIndex: int
    matchOrder: int

  RenderSegment = object
    startByte: int
    endByte: int
    cssClass: string

  HighlighterState = object
    initialized: bool
    available: bool
    parser: ptr TsParser
    query: ptr TsQuery

var
  highlighters: Table[string, HighlighterState]
  warnedMessages: HashSet[string]

proc warnOnce(msg: string) =
  if warnedMessages.len == 0:
    warnedMessages = initHashSet[string]()
  if not warnedMessages.containsOrIncl(msg):
    stderr.writeLine "[WARN]: " & msg

proc asString(data: cstring, size: uint32): string =
  result.setLen(size.int)
  for i in 0..<size.int:
    result[i] = data[i]

proc captureName(query: ptr TsQuery, captureId: uint32): string =
  var captureLen: uint32
  let captureText = tsQueryCaptureNameForId(query, captureId, captureLen.addr)
  result = asString(captureText, captureLen)

proc stringValue(query: ptr TsQuery, stringId: uint32): string =
  var stringLen: uint32
  let value = tsQueryStringValueForId(query, stringId, stringLen.addr)
  result = asString(value, stringLen)

proc captureTexts(match: TsQueryMatch, captureId: uint32, source: string): seq[string] =
  let captures = cast[ptr UncheckedArray[TsQueryCapture]](match.captures)
  for i in 0..<match.captureCount.int:
    let capture = captures[i]
    if capture.index != captureId:
      continue

    let
      startByte = min(tsNodeStartByte(capture.node).int, source.len)
      endByte = min(tsNodeEndByte(capture.node).int, source.len)

    if startByte < endByte:
      result.add(source[startByte..<endByte])

proc compareAll(lhs, rhs: seq[string], equal: bool): bool =
  result = lhs.len > 0 and rhs.len > 0
  if result:
    for left in lhs:
      if result:
        for right in rhs:
          if (left == right) != equal:
            result = false

proc compareAny(lhs, rhs: seq[string], equal: bool): bool =
  result = false
  if lhs.len > 0 and rhs.len > 0:
    for left in lhs:
      if not result:
        for right in rhs:
          if (left == right) == equal:
            result = true

proc matchAll(values: seq[string], pattern: string, equal: bool): bool =
  result = values.len > 0
  if result:
    try:
      let regex = re(pattern)
      for value in values:
        if (value.contains(regex)) != equal:
          result = false
    except RegexError:
      warnOnce("tree-sitter regex predicate failed to compile: " & pattern)
      result = false

proc matchAny(values: seq[string], pattern: string, equal: bool): bool =
  result = false
  if values.len > 0:
    try:
      let regex = re(pattern)
      for value in values:
        if not result and (value.contains(regex)) == equal:
          result = true
    except RegexError:
      warnOnce("tree-sitter regex predicate failed to compile: " & pattern)

proc predicateValues(
  query: ptr TsQuery,
  `match`: TsQueryMatch,
  source: string,
  step: TsQueryPredicateStep,
): seq[string] =
  case step.`type`
  of TsQueryPredicateStepTypeCapture:
    result = captureTexts(`match`, step.valueId, source)
  of TsQueryPredicateStepTypeString:
    result = @[stringValue(query, step.valueId)]
  else:
    discard

proc evaluatePredicate(
  query: ptr TsQuery,
  `match`: TsQueryMatch,
  source: string,
  steps: openArray[TsQueryPredicateStep],
): bool =
  result = false
  if steps.len > 0 and steps[0].`type` == TsQueryPredicateStepTypeString:
    let
      rawOp = stringValue(query, steps[0].valueId)
      op = if rawOp.startsWith('#'): rawOp[1..^1] else: rawOp
    case op
    of "eq?", "not-eq?", "any-eq?", "any-not-eq?":
      if steps.len == 3:
        let
          lhs = predicateValues(query, `match`, source, steps[1])
          rhs = predicateValues(query, `match`, source, steps[2])
        case op
        of "eq?":
          result = compareAll(lhs, rhs, equal = true)
        of "not-eq?":
          result = compareAll(lhs, rhs, equal = false)
        of "any-eq?":
          result = compareAny(lhs, rhs, equal = true)
        else:
          result = compareAny(lhs, rhs, equal = false)
    of "match?", "not-match?", "any-match?", "any-not-match?":
      if steps.len == 3:
        let
          lhs = predicateValues(query, `match`, source, steps[1])
          rhs = predicateValues(query, `match`, source, steps[2])
        if rhs.len == 1:
          case op
          of "match?":
            result = matchAll(lhs, rhs[0], equal = true)
          of "not-match?":
            result = matchAll(lhs, rhs[0], equal = false)
          of "any-match?":
            result = matchAny(lhs, rhs[0], equal = true)
          else:
            result = matchAny(lhs, rhs[0], equal = false)
    of "is?", "is-not?":
      if steps.len == 2 and steps[1].`type` == TsQueryPredicateStepTypeString:
        let prop = stringValue(query, steps[1].valueId)
        if prop == "local":
          result = op == "is-not?"
        else:
          warnOnce("tree-sitter predicate property not yet supported: " & prop)
    of "any-of?":
      if steps.len >= 3:
        let lhs = predicateValues(query, `match`, source, steps[1])
        if lhs.len > 0:
          var
            rhs: seq[string]
            valid = true
          for i in 2..<steps.len:
            if steps[i].`type` == TsQueryPredicateStepTypeString:
              rhs.add(stringValue(query, steps[i].valueId))
            else:
              valid = false
          if valid:
            for value in lhs:
              if not result and value in rhs:
                result = true
    else:
      warnOnce("tree-sitter predicate not yet supported: " & op)

proc evaluatePredicates(query: ptr TsQuery, `match`: TsQueryMatch, source: string): bool =
  var stepCount: uint32
  let steps = tsQueryPredicatesForPattern(query, `match`.patternIndex.uint32, stepCount.addr)
  result = true
  if not steps.isNil and stepCount != 0:
    let allSteps = cast[ptr UncheckedArray[TsQueryPredicateStep]](steps)
    var i = 0
    while i < stepCount.int and result:
      let predicateStart = i
      while i < stepCount.int and allSteps[i].`type` != TsQueryPredicateStepTypeDone:
        inc i
      if i > predicateStart:
        result = evaluatePredicate(query, `match`, source, allSteps.toOpenArray(predicateStart, i - 1))
      inc i

proc ensureHighlighter(spec: LanguageSpec): bool =
  result = false
  if spec.name.len > 0 and spec.highlightQuery.len > 0:
    if spec.name notin highlighters:
      highlighters[spec.name] = HighlighterState()
    if highlighters[spec.name].initialized:
      result = highlighters[spec.name].available
    else:
      highlighters[spec.name].initialized = true

      let language = newTsLang(spec.name)
      if language.isNil:
        warnOnce("tree-sitter parser for " & spec.name & " is not installed; using plain code blocks")
      else:
        let parser = tsParserNew()
        if parser.isNil:
          warnOnce("tree-sitter parser allocation failed; using plain code blocks")
        elif not tsParserSetLanguage(parser, language):
          warnOnce("tree-sitter language ABI for " & spec.name & " is incompatible; using plain code blocks")
          tsParserDelete(parser)
        else:
          var
            queryErrorOffset: uint32
            queryErrorType: cint = TsQueryErrorNone

          let query = tsQueryNew(
            language,
            spec.highlightQuery.cstring,
            spec.highlightQuery.len.uint32,
            queryErrorOffset.addr,
            queryErrorType.addr,
          )

          if query.isNil:
            warnOnce("tree-sitter highlight query for " & spec.name & " failed to compile at byte " & $queryErrorOffset)
            tsParserDelete(parser)
          else:
            highlighters[spec.name].available = true
            highlighters[spec.name].parser = parser
            highlighters[spec.name].query = query
            result = true

proc captureSpecificity(captureName: string): int =
  result = 1
  for ch in captureName:
    if ch == '.':
      inc result

proc isBetterCapture(candidate, current: CaptureRange): bool =
  let
    candidateSpecificity = captureSpecificity(candidate.captureName)
    currentSpecificity = captureSpecificity(current.captureName)

  if candidateSpecificity != currentSpecificity:
    result = candidateSpecificity > currentSpecificity
  elif candidate.patternIndex != current.patternIndex:
    result = candidate.patternIndex < current.patternIndex
  else:
    result = candidate.matchOrder < current.matchOrder

proc captureClasses(captureName: string): string =
  result = "ts-capture"
  var current = ""
  for part in captureName.split('.'):
    if current.len == 0:
      current = part
    else:
      current.add('-')
      current.add(part)
    result.add(" ts-")
    result.add(current)

proc addRenderedSegment(
  dst: var string,
  source: string,
  startByte, endByte: int,
  cssClass: string,
) =
  if startByte >= endByte:
    return

  if cssClass.len > 0:
    dst.add("<span class=\"")
    dst.add(cssClass)
    dst.add("\">")
    dst.addHtmlEscaped(source, startByte, endByte)
    dst.add("</span>")
  else:
    dst.addHtmlEscaped(source, startByte, endByte)

proc renderSegments(source: string, captures: seq[CaptureRange]): seq[RenderSegment] =
  var boundaries = newSeq[int](0)
  boundaries.add(0)
  boundaries.add(source.len)
  for capture in captures:
    boundaries.add(capture.startByte)
    boundaries.add(capture.endByte)
  boundaries.sort()

  var deduped = newSeq[int](0)
  for boundary in boundaries:
    if deduped.len == 0 or deduped[^1] != boundary:
      deduped.add(boundary)

  for i in 0..<(deduped.len - 1):
    let
      startByte = deduped[i]
      endByte = deduped[i + 1]

    if startByte >= endByte:
      continue

    var winner: CaptureRange
    var hasWinner = false
    for capture in captures:
      if capture.startByte <= startByte and endByte <= capture.endByte:
        if not hasWinner or isBetterCapture(capture, winner):
          winner = capture
          hasWinner = true

    if hasWinner:
      result.add(RenderSegment(
        startByte: startByte,
        endByte: endByte,
        cssClass: captureClasses(winner.captureName),
      ))
    else:
      result.add(RenderSegment(
        startByte: startByte,
        endByte: endByte,
      ))

proc renderCodeHtml(source: string, segments: seq[RenderSegment], showLineNumbers: bool): string =
  if showLineNumbers:
    result.add("<span class=\"code-line\"><span class=\"code-line-content\">")
    var hasOpenLine = true
    for segment in segments:
      var
        chunkStart = segment.startByte
        i = segment.startByte

      while i < segment.endByte:
        if source[i] == '\n':
          addRenderedSegment(result, source, chunkStart, i, segment.cssClass)
          result.add("</span></span>\n")
          hasOpenLine = false
          if i + 1 < source.len:
            result.add("<span class=\"code-line\"><span class=\"code-line-content\">")
            hasOpenLine = true
          chunkStart = i + 1
        inc i

      addRenderedSegment(result, source, chunkStart, segment.endByte, segment.cssClass)
    if hasOpenLine:
      result.add("</span></span>")
  else:
    for segment in segments:
      addRenderedSegment(result, source, segment.startByte, segment.endByte, segment.cssClass)

proc plainCode(source, languageClass: string, showLineNumbers: bool): HighlightResult =
  result.languageClass = languageClass
  result.html = renderCodeHtml(
    source,
    @[RenderSegment(startByte: 0, endByte: source.len)],
    showLineNumbers,
  )

proc highlightTreeSitter(
  source,
  languageClass: string,
  spec: LanguageSpec,
  showLineNumbers: bool,
): HighlightResult =
  if ensureHighlighter(spec):
    let highlighter = highlighters[spec.name]

    let tree = tsParserParseString(
      highlighter.parser,
      nil,
      source.cstring,
      source.len.uint32,
    )

    if tree.isNil:
      warnOnce("tree-sitter failed to parse " & spec.name & " code block; using plain code blocks")
      result = plainCode(source, languageClass, showLineNumbers)
    else:
      defer:
        tsTreeDelete(tree)

      let
        root = tsTreeRootNode(tree)
        cursor = tsQueryCursorNew()

      if cursor.isNil:
        warnOnce("tree-sitter query cursor allocation failed; using plain code blocks")
        result = plainCode(source, languageClass, showLineNumbers)
      else:
        defer:
          tsQueryCursorDelete(cursor)

        tsQueryCursorExec(cursor, highlighter.query, root)

        var
          ranges: seq[CaptureRange]
          matchOrder = 0
          queryMatch: TsQueryMatch

        while tsQueryCursorNextMatch(cursor, queryMatch.addr):
          if evaluatePredicates(highlighter.query, queryMatch, source):
            let captures = cast[ptr UncheckedArray[TsQueryCapture]](queryMatch.captures)
            for i in 0..<queryMatch.captureCount.int:
              let
                capture = captures[i]
                startByte = min(tsNodeStartByte(capture.node).int, source.len)
                endByte = min(tsNodeEndByte(capture.node).int, source.len)

              if startByte < endByte:
                ranges.add(CaptureRange(
                  startByte: startByte,
                  endByte: endByte,
                  captureName: captureName(highlighter.query, capture.index),
                  patternIndex: queryMatch.patternIndex.int,
                  matchOrder: matchOrder,
                ))
                inc matchOrder

        if ranges.len == 0:
          result = plainCode(source, languageClass, showLineNumbers)
        else:
          result.languageClass = languageClass
          result.highlighted = true
          result.html = renderCodeHtml(source, renderSegments(source, ranges), showLineNumbers)
  else:
    result = plainCode(source, languageClass, showLineNumbers)

proc highlightCode*(source, language: string, showLineNumbers = false): HighlightResult =
  let languageClass = normalizeCodeLanguage(language)
  let spec = LanguageSpecs.getOrDefault(languageClass)

  if spec.name.len == 0:
    result = plainCode(source, languageClass, showLineNumbers)
  else:
    result = highlightTreeSitter(source, languageClass, spec, showLineNumbers)

proc highlightedCodeBlockOutput*(dst: var string, code: Str8, options: CodeBlockOptions) =
  let highlighted = highlightCode($code, options.language, options.showLineNumbers)
  dst.add("<pre")
  if options.showLineNumbers:
    dst.add(" class=\"code-block-pre has-line-numbers\"")
  else:
    dst.add(" class=\"code-block-pre\"")
  dst.add("><code")
  if highlighted.languageClass.len > 0:
    dst.add(" class=\"language-")
    dst.add(highlighted.languageClass)
    dst.add("\"")
  if highlighted.highlighted:
    dst.add(" data-highlighter=\"tree-sitter\"")
  dst.add(">")
  dst.add(highlighted.html)
  dst.add("</code></pre>\n")
