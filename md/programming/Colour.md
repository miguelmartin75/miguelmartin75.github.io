---
title: Colour
tags: cg
---

# Differences in Color Spaces

# Notes from SO
Reference: https://stackoverflow.com/a/12894053
## Linear Colour Space and sRGB
- Linear colour space means that the mapping between the intensity the colour represents is linear
- Humans can distinguish more dark than light shades, due to this, we use sRGB
- sRGB is a mapping from linear space using a non-linear curve. The curve is "steep" at the light side to compress the values. This is done to maximize the amount of usable information (w.r.t a human) if the colour intensity is being stored in a fixed number of bits.
- Blending needs to be done in linear space, as you can add, subtract, multiply, divide etc. 
- When storing into a texture or putting a color onto the screen, monitors and etc. interpret the color as sRGB
- *Don't use 8-bit linear colours*. 8-bit is fine for sRGB, but for converting sRGB -> RGB (linear) you will lose information

Formulate for sRGB to Linear (reading to Linear)
```
float s = read_channel();
float linear;
if (s <= 0.04045) linear = s / 12.92;
else linear = pow((s + 0.055) / 1.055, 2.4);
```

Writing to sRGB:
```
float linear = do_processing();
float s;
if (linear <= 0.0031308) s = linear * 12.92;
else s = 1.055 * pow(linear, 1.0/2.4) - 0.055; ( Edited: The previous version is -0.55 )
```

## YUV, YCrCb, etc.
- Humans can tell more brightnesses compared to tints
- Store brightness seperate from tint
- YUV is linear color space
	- Can't add or multiply colors together similar to RGB; used for storage and transmission
	- Y is overall lightness, has more bits (or more spatial resolution)

