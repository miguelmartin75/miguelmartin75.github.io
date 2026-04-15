{.passC: "-I3rdparty/tree-sitter/lib/include -I3rdparty/tree-sitter/lib/src".}
{.compile: "3rdparty/tree-sitter/lib/src/lib.c".}

type
  TsLanguage* {.importc: "TSLanguage", header: "tree_sitter/api.h", incompleteStruct.} = object
  TsParser* {.importc: "TSParser", header: "tree_sitter/api.h", incompleteStruct.} = object
  TsTree* {.importc: "TSTree", header: "tree_sitter/api.h", incompleteStruct.} = object
  TsQuery* {.importc: "TSQuery", header: "tree_sitter/api.h", incompleteStruct.} = object
  TsQueryCursor* {.importc: "TSQueryCursor", header: "tree_sitter/api.h", incompleteStruct.} = object

  TsPoint* {.importc: "TSPoint", header: "tree_sitter/api.h", bycopy.} = object
    row*: uint32
    column*: uint32

  TsNode* {.importc: "TSNode", header: "tree_sitter/api.h", bycopy.} = object
    context*: array[4, uint32]
    id*: pointer
    tree*: ptr TsTree

  TsQueryCapture* {.importc: "TSQueryCapture", header: "tree_sitter/api.h", bycopy.} = object
    node*: TsNode
    index*: uint32

  TsQueryMatch* {.importc: "TSQueryMatch", header: "tree_sitter/api.h", bycopy.} = object
    id*: uint32
    patternIndex* {.importc: "pattern_index".}: uint16
    captureCount* {.importc: "capture_count".}: uint16
    captures*: ptr TsQueryCapture

  TsQueryPredicateStep* {.importc: "TSQueryPredicateStep", header: "tree_sitter/api.h", bycopy.} = object
    `type`*: cint
    valueId* {.importc: "value_id".}: uint32

const
  TsQueryPredicateStepTypeDone* = 0.cint
  TsQueryPredicateStepTypeCapture* = 1.cint
  TsQueryPredicateStepTypeString* = 2.cint

  TsQueryErrorNone* = 0.cint

proc tsParserNew*(): ptr TsParser {.cdecl, importc: "ts_parser_new", header: "tree_sitter/api.h".}
proc tsParserDelete*(self: ptr TsParser) {.cdecl, importc: "ts_parser_delete", header: "tree_sitter/api.h".}
proc tsParserSetLanguage*(self: ptr TsParser, language: ptr TsLanguage): bool {.cdecl, importc: "ts_parser_set_language", header: "tree_sitter/api.h".}
proc tsParserParseString*(self: ptr TsParser, oldTree: ptr TsTree, str: cstring, len: uint32): ptr TsTree {.cdecl, importc: "ts_parser_parse_string", header: "tree_sitter/api.h".}

proc tsTreeDelete*(self: ptr TsTree) {.cdecl, importc: "ts_tree_delete", header: "tree_sitter/api.h".}
proc tsTreeRootNode*(self: ptr TsTree): TsNode {.cdecl, importc: "ts_tree_root_node", header: "tree_sitter/api.h".}

proc tsNodeStartByte*(self: TsNode): uint32 {.cdecl, importc: "ts_node_start_byte", header: "tree_sitter/api.h".}
proc tsNodeEndByte*(self: TsNode): uint32 {.cdecl, importc: "ts_node_end_byte", header: "tree_sitter/api.h".}

proc tsQueryNew*(
  language: ptr TsLanguage,
  source: cstring,
  sourceLen: uint32,
  errorOffset: ptr uint32,
  errorType: ptr cint,
): ptr TsQuery {.cdecl, importc: "ts_query_new", header: "tree_sitter/api.h".}

proc tsQueryDelete*(self: ptr TsQuery) {.cdecl, importc: "ts_query_delete", header: "tree_sitter/api.h".}
proc tsQueryPredicatesForPattern*(
  self: ptr TsQuery,
  patternIndex: uint32,
  stepCount: ptr uint32,
): ptr TsQueryPredicateStep {.cdecl, importc: "ts_query_predicates_for_pattern", header: "tree_sitter/api.h".}

proc tsQueryCaptureNameForId*(
  self: ptr TsQuery,
  index: uint32,
  length: ptr uint32,
): cstring {.cdecl, importc: "ts_query_capture_name_for_id", header: "tree_sitter/api.h".}

proc tsQueryStringValueForId*(
  self: ptr TsQuery,
  index: uint32,
  length: ptr uint32,
): cstring {.cdecl, importc: "ts_query_string_value_for_id", header: "tree_sitter/api.h".}

proc tsQueryCursorNew*(): ptr TsQueryCursor {.cdecl, importc: "ts_query_cursor_new", header: "tree_sitter/api.h".}
proc tsQueryCursorDelete*(self: ptr TsQueryCursor) {.cdecl, importc: "ts_query_cursor_delete", header: "tree_sitter/api.h".}
proc tsQueryCursorExec*(self: ptr TsQueryCursor, query: ptr TsQuery, node: TsNode) {.cdecl, importc: "ts_query_cursor_exec", header: "tree_sitter/api.h".}
proc tsQueryCursorNextMatch*(self: ptr TsQueryCursor, `match`: ptr TsQueryMatch): bool {.cdecl, importc: "ts_query_cursor_next_match", header: "tree_sitter/api.h".}
