---
title: Text Rendering
---

https://learnopengl.com/In-Practice/Text-Rendering

- Rasterization: rendering a glyph to pixels
- Shaping:
  - how to layout a sequence of glyphs on multiple lines
  - may not be straight-forward such as for latin languages

# CoreText / CoreGraphics
## Notes on Metal
- [Blog post](https://medium.com/@s1ddok/combine-the-power-of-coregraphics-and-metal-by-sharing-resource-memory-eabb4c1be615)

Steps:
1. Create CGContext
2. Create MTLBuffer pointing to same memory
   1. Write to MTLBuffer with CGContext
3. Create MTLTexture out of MTLBuffer

* FreeType / Harfbuzz
- FreeType for rasterization
- Harfbuzz for shaping

## Create a font with Harfbuzz

```c
#include <hb-ft.h>
FT_New_Face(ft_library, font_path, index, &face);
FT_Set_Char_Size(face, 0, 1000, 0, 0);
hb_font_t *font = hb_ft_font_create(face);
```

