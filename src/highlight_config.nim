import std/[algorithm, json, os, strutils, tables]

type
  SyntaxFontStyle* = enum
    sfsBold
    sfsItalic
    sfsUnderline

  SyntaxStyle* = object
    fg*: string
    bg*: string
    styles*: seq[SyntaxFontStyle]

  SyntaxTheme* = object
    name*: string
    codeBg*: string
    codeBorder*: string
    tokens*: Table[string, SyntaxStyle]

  SyntaxStyleSource* = enum
    sssRaw
    sssAlias

  ResolvedSyntaxStyle* = object
    matched*: bool
    source*: SyntaxStyleSource
    resolvedKey*: string
    style*: SyntaxStyle

  TokenCssRule = object
    key: string
    style: SyntaxStyle

const
  HighlightThemesDir = currentSourcePath().parentDir.parentDir / "themes" / "highlight"
  HighlightAliases* = [
    ("parameter", "variable.parameter"),
    ("method", "function.method"),
    ("conditional", "keyword.control.conditional"),
    ("repeat", "keyword.control.repeat"),
    ("include", "keyword.control.import"),
    ("exception", "keyword.control.exception"),
  ]

proc tokenSpecificity(tokenKey: string): int {.inline.} =
  result = 1
  for ch in tokenKey:
    if ch == '.':
      inc result

proc tokenClassName(tokenKey: string): string {.inline.} =
  result = tokenKey.replace(".", "-")

proc themeFileName*(themeName: string): string =
  result = themeName.strip.toLowerAscii

proc themePath(themeName: string): string {.inline.} =
  result = HighlightThemesDir / (themeFileName(themeName) & ".json")

proc requireObject(node: JsonNode, ctx: string) =
  if node.kind != JObject:
    raise newException(ValueError, ctx & " must be a JSON object")

proc requireStringField(node: JsonNode, fieldName, ctx: string): string =
  if not node.hasKey(fieldName) or node[fieldName].kind != JString:
    raise newException(ValueError, ctx & " is missing string field '" & fieldName & "'")
  result = node[fieldName].getStr

proc optionalStringField(node: JsonNode, fieldName: string): string =
  if node.hasKey(fieldName):
    if node[fieldName].kind != JString:
      raise newException(ValueError, "field '" & fieldName & "' must be a string")
    result = node[fieldName].getStr

proc capturePrefixes(captureName: string): seq[string] =
  var current = captureName
  while current.len > 0:
    result.add(current)
    let idx = current.rfind('.')
    if idx == -1:
      current.setLen(0)
    else:
      current.setLen(idx)

proc parseSyntaxFontStyle(styleName: string): SyntaxFontStyle =
  case styleName
  of "sfsBold":
    result = sfsBold
  of "sfsItalic":
    result = sfsItalic
  of "sfsUnderline":
    result = sfsUnderline
  else:
    raise newException(ValueError, "unknown syntax font style: " & styleName)

proc aliasTarget(captureName: string): string =
  for (source, target) in HighlightAliases:
    if source == captureName:
      result = target
      return

proc parseSyntaxStyle(node: JsonNode): SyntaxStyle =
  requireObject(node, "syntax style")

  result.fg = optionalStringField(node, "fg")
  result.bg = optionalStringField(node, "bg")

  if node.hasKey("styles"):
    if node["styles"].kind != JArray:
      raise newException(ValueError, "field 'styles' must be an array")

    for styleNode in node["styles"].items:
      if styleNode.kind != JString:
        raise newException(ValueError, "syntax style entries must be strings")
      result.styles.add(parseSyntaxFontStyle(styleNode.getStr))

proc loadSyntaxTheme*(themeName: string): SyntaxTheme =
  let
    normalizedThemeName = themeFileName(themeName)
    path = themePath(normalizedThemeName)

  if not fileExists(path):
    raise newException(ValueError, "unknown highlight theme name: " & themeName)

  let root = parseFile(path)
  requireObject(root, "syntax theme")

  result.name = themeFileName(requireStringField(root, "name", "syntax theme"))
  doAssert result.name == normalizedThemeName
  result.codeBg = requireStringField(root, "codeBg", "syntax theme")
  result.codeBorder = requireStringField(root, "codeBorder", "syntax theme")
  result.tokens = initTable[string, SyntaxStyle]()

  if not root.hasKey("tokens") or root["tokens"].kind != JObject:
    raise newException(ValueError, "syntax theme is missing object field 'tokens'")

  for key, value in root["tokens"]:
    result.tokens[key] = parseSyntaxStyle(value)

proc resolveRawStyle(theme: SyntaxTheme, captureName: string): ResolvedSyntaxStyle =
  for rawKey in capturePrefixes(captureName):
    if rawKey in theme.tokens:
      result.matched = true
      result.source = sssRaw
      result.resolvedKey = rawKey
      result.style = theme.tokens[rawKey]
      return

proc resolveAliasStyle(theme: SyntaxTheme, captureName: string): ResolvedSyntaxStyle =
  for rawKey in capturePrefixes(captureName):
    let aliasKey = aliasTarget(rawKey)
    if aliasKey.len == 0:
      continue

    for aliasPrefix in capturePrefixes(aliasKey):
      if aliasPrefix in theme.tokens:
        result.matched = true
        result.source = sssAlias
        result.resolvedKey = aliasPrefix
        result.style = theme.tokens[aliasPrefix]
        return

proc resolveSyntaxStyle*(theme: SyntaxTheme, captureName: string): ResolvedSyntaxStyle =
  result = resolveRawStyle(theme, captureName)
  if not result.matched:
    result = resolveAliasStyle(theme, captureName)

proc addDeclaration(dst: var string, name, value: string) =
  if value.len > 0:
    dst.add("  ")
    dst.add(name)
    dst.add(": ")
    dst.add(value)
    dst.add(";\n")

proc addFontStyle(dst: var string, fontStyle: SyntaxFontStyle) =
  case fontStyle
  of sfsBold:
    dst.add("  font-weight: bold;\n")
  of sfsItalic:
    dst.add("  font-style: italic;\n")
  of sfsUnderline:
    dst.add("  text-decoration: underline;\n")

proc renderTokenCssRule(rule: TokenCssRule): string =
  result.add("pre > code .ts-")
  result.add(tokenClassName(rule.key))
  result.add(" {\n")
  addDeclaration(result, "color", rule.style.fg)
  addDeclaration(result, "background-color", rule.style.bg)
  for fontStyle in rule.style.styles:
    addFontStyle(result, fontStyle)
  result.add("}\n")

proc collectTokenCssRules(theme: SyntaxTheme): seq[TokenCssRule] =
  for key, style in theme.tokens:
    result.add(TokenCssRule(key: key, style: style))

  for (rawKey, _) in HighlightAliases:
    if rawKey in theme.tokens:
      continue

    let resolved = resolveSyntaxStyle(theme, rawKey)
    if resolved.matched and resolved.source == sssAlias:
      result.add(TokenCssRule(key: rawKey, style: resolved.style))

  result.sort(proc(a, b: TokenCssRule): int =
    result = cmp(tokenSpecificity(a.key), tokenSpecificity(b.key))
    if result == 0:
      result = cmp(a.key, b.key)
  )

proc renderSyntaxTokenCss*(theme: SyntaxTheme): string =
  let rules = collectTokenCssRules(theme)
  for i, rule in rules:
    if i > 0:
      result.add("\n")
    result.add(renderTokenCssRule(rule))
