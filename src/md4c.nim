{.passC: "-I3rdparty/md4c/src".}
{.compile: "3rdparty/md4c/src/md4c.c".}
# NOTE: for no html tags
{.compile: "3rdparty/md4c/src/md4c-html.c".}
{.compile: "3rdparty/md4c/src/entity.c".}

const
  MD_FLAG_COLLAPSEWHITESPACE          : cuint = 0x0001  # In MD_TEXT_NORMAL, collapse non-trivial whitespace into single ' ' */
  MD_FLAG_PERMISSIVEATXHEADERS        : cuint = 0x0002  # Do not require space in ATX headers ( ###header ) */
  MD_FLAG_PERMISSIVEURLAUTOLINKS      : cuint = 0x0004  # Recognize URLs as autolinks even without '<', '>' */
  MD_FLAG_PERMISSIVEEMAILAUTOLINKS    : cuint = 0x0008  # Recognize e-mails as autolinks even without '<', '>' and 'mailto:' */
  MD_FLAG_NOINDENTEDCODEBLOCKS        : cuint = 0x0010  # Disable indented code blocks. (Only fenced code works.) */
  MD_FLAG_NOHTMLBLOCKS                : cuint = 0x0020  # Disable raw HTML blocks. */
  MD_FLAG_NOHTMLSPANS                 : cuint = 0x0040  # Disable raw HTML (inline). */
  MD_FLAG_TABLES                      : cuint = 0x0100  # Enable tables extension. */
  MD_FLAG_STRIKETHROUGH               : cuint = 0x0200  # Enable strikethrough extension. */
  MD_FLAG_PERMISSIVEWWWAUTOLINKS      : cuint = 0x0400  # Enable WWW autolinks (even without any scheme prefix, if they begin with 'www.') */
  MD_FLAG_TASKLISTS                   : cuint = 0x0800  # Enable task list extension. */
  MD_FLAG_LATEXMATHSPANS              : cuint = 0x1000  # Enable $ and $$ containing LaTeX equations. */
  MD_FLAG_WIKILINKS                   : cuint = 0x2000  # Enable wiki links extension. */
  MD_FLAG_UNDERLINE                   : cuint = 0x4000  # Enable underline extension (and disables '_' for normal emphasis). */
  MD_FLAG_HARD_SOFT_BREAKS            : cuint = 0x8000  # Force all soft breaks to act as hard breaks. */
  MD_FLAG_PERMISSIVEAUTOLINKS*        : cuint = (MD_FLAG_PERMISSIVEEMAILAUTOLINKS or MD_FLAG_PERMISSIVEURLAUTOLINKS or MD_FLAG_PERMISSIVEWWWAUTOLINKS)
  MD_FLAG_NOHTML*                     : cuint = (MD_FLAG_NOHTMLBLOCKS or MD_FLAG_NOHTMLSPANS)
  MD_DIALECT_COMMONMARK*               : cuint = 0
  MD_DIALECT_GITHUB*                   : cuint = (MD_FLAG_PERMISSIVEAUTOLINKS or MD_FLAG_TABLES or MD_FLAG_STRIKETHROUGH or MD_FLAG_TASKLISTS)

# TODO: moveme
type 
  Str8* = object
    data: cstring
    len: int64

proc s8(x: string): Str8 {.inline.} = Str8(data: x.cstring, len: x.len)
proc toString(x: Str8): string {.inline.} = 
  result.setLen(x.len)
  for i in 0..<x.len:
    result[i] = x.data[i]

proc md_html*(
  input: ptr char,
  input_size: cuint,
  process_output: proc(ch: cstring, len: cuint, userdata: pointer) {.cdecl.},
  userdata: pointer,
  parser_flags: cuint,
  renderer_flags: cuint,
): int {.cdecl, importc, header: "md4c-html.h".}

proc mdToHtml*(
  data: string,
  parser_flags: cuint = (
    MD_FLAG_TASKLISTS or 
    MD_FLAG_UNDERLINE or 
    MD_FLAG_LATEXMATHSPANS or
    MD_DIALECT_GITHUB or
    MD_FLAG_NOINDENTEDCODEBLOCKS  # an annoying feature disabled :)
  ),
  renderer_flags: cuint = 0,
): string = 
  proc convertHtml(ch: cstring, len: cuint, userdata: pointer) {.cdecl.} =
    let s = Str8(data: ch, len: len.int64)
    cast[ptr string](userdata)[] &= s.toString

  doAssert md_html(
    data[0].addr, data.len.cuint, 
    convertHtml,
    result.addr,
    parser_flags,
    renderer_flags,
  ) == 0

when isMainModule:
  let data = """
# h1 test
- [ ] a
- b

$1 + 2$

$$ 3 * 5 $$
"""

  let output = mdToHtml(data)
  echo output
