https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Overview/Overview.html#//apple_ref/doc/uid/TP40005533-CH3-SW9

- Opaque types
	- Works mostly with attributed strings and graphic paths
	- Attributed String define stylistic aspects of the chars of the string, e.g. font and colour
	- Graphics path defines shape of a text; paths can be non-rectangular -- not sure what this means
	- `CFAttributedStringRef` is bridged to NSAttributedString "toll tree"
	- Attributes can be specified to specific glyph runs (CTRun)
	- Individual attributes may not be toll free in dict
- hierarchy ![[Screen Shot 2023-03-02 at 10.16.23 PM.png]]
	- CTFramesetter generates one or more frames of text (CTFrameRef)
		- Each CTFrameRef refers to a paragraph
	- To generate frames, the framesetter calls a typesetter (`CTTypesetterRef`)
		- Framesetter applies styles, such as alignment, tab stops, line spacing, indentation and line break mode
		- Typesetter converts chars in attr str to glyphs and fits the glyphs into the lines that fill a text frame
	- CTFrame contains a sequence of CTLine objects (representing a line of text)
	- Each CTLine contains a glyph run (CTRun)
- CTFont
	- CTFont is bridged between NSFont on OSX and UIFont on iOS
		- You can query this object to obtain a char to glyph mapping, encodings, font metric data and glyph data. Font metric data is ascent, descent, leading, cap height, x-height, etc.
		- Immutable so they can be used safely in multi-threading situtations
		- **Font cascading**
			- CTFont supports automatic font-substitution called font cascading, which allows picking an appropriate font to subsitute for a missing font
			- *Likely useful for mixing font types* 
	- Get all available fonts from CoreText: https://developer.apple.com/documentation/coretext/1509907-ctfontcollectioncreatefromavaila?language=objc
	- Get Glyphs 
		1. get unicode chars: `CFStringGetCharacters(font, chars, glyphs, count) -> UniChar[]`
			- [UniChar is UTF16](https://developer.apple.com/documentation/kernel/unichar/)
		2. get glyphs for `CTFontGetGlyphsForCharacters`