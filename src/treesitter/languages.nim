import std/[os, strutils, tables]

import bindings

type
  LanguageSpec* = object
    name*: string
    parserPath*: string
    scannerPath*: string
    importSymbol*: string
    highlightQuery*: string

const
  TreeSitterParsersDir = currentSourcePath().parentDir.parentDir.parentDir / "3rdparty" / "tree-sitter-parsers"
  NimHighlightQuery = staticRead(currentSourcePath().parentDir / "queries" / "nim" / "highlights.scm")
  JavaScriptHighlightQuery =
    staticRead(TreeSitterParsersDir / "javascript" / "queries" / "highlights.scm") & "\n" &
    staticRead(TreeSitterParsersDir / "javascript" / "queries" / "highlights-jsx.scm") & "\n" &
    staticRead(TreeSitterParsersDir / "javascript" / "queries" / "highlights-params.scm")

  LanguageSpecs* = [
    (
      "javascript",
      LanguageSpec(
        name: "javascript",
        parserPath: "3rdparty/tree-sitter-parsers/javascript/src/parser.c",
        scannerPath: "3rdparty/tree-sitter-parsers/javascript/src/scanner.c",
        importSymbol: "tree_sitter_javascript",
        highlightQuery: JavaScriptHighlightQuery,
      ),
    ),
    (
      "nim",
      LanguageSpec(
        name: "nim",
        parserPath: "3rdparty/tree-sitter-parsers/nim/src/parser.c",
        scannerPath: "3rdparty/tree-sitter-parsers/nim/src/scanner.c",
        importSymbol: "tree_sitter_nim",
        highlightQuery: NimHighlightQuery,
      ),
    ),
  ].toTable

  LanguageAliases = [
    ("js", "javascript"),
    ("jsx", "javascript"),
    ("mjs", "javascript"),
    ("cjs", "javascript"),
    ("nimble", "nim"),
    ("nims", "nim"),
    ("python-interactive", "python"),
    ("text", ""),
    ("toc", ""),
  ].toTable

template declareTsParser(lang: static[string], procName: untyped) =
  const spec = LanguageSpecs[lang]
  when fileExists(spec.parserPath):
    {.compile: spec.parserPath.}
    when fileExists(spec.scannerPath):
      {.compile: spec.scannerPath.}
    proc procName(): ptr TsLanguage {.cdecl, importc: spec.importSymbol.}
  else:
    proc procName(): ptr TsLanguage {.cdecl.} =
      return nil

{.passC: "-I3rdparty/tree-sitter/lib/include -I3rdparty/tree-sitter/lib/src".}
declareTsParser("javascript", treeSitterJavascript)
declareTsParser("nim", treeSitterNim)

proc normalizeCodeLanguage*(language: string): string =
  let raw = language.strip.toLowerAscii
  result = LanguageAliases.getOrDefault(raw, raw)

proc newTsLang*(language: string): ptr TsLanguage =
  case language
  of "javascript":
    result = treeSitterJavascript()
  of "nim":
    result = treeSitterNim()
  else:
    result = nil
