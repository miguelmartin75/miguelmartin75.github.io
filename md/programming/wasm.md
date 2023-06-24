- related: [[WAMR]]

- How to access glyphs and shape the font with a layout? Do we need FreeType?
	- https://github.com/Celtoys/Remotery uses `document.fonts.load`
https://github.com/Celtoys/Remotery/blob/main/vis/Code/WebGLFont.js
```js
this.charCanvas = document.createElement("canvas");
this.charContext = this.charCanvas.getContext("2d");


const font_size = 9;
this.fontWidth = 5;
this.fontHeight = 13;
const font_face = "LocalFiraCode";
const font_desc = font_size + "px " + font_face;
document.fonts.load(font_desc).then(...);


render_text_to_canvas(tet, font, width, height) {
	this.charCanvas.getContext("2d");
	this.charContext.font = font;
	this.charContext.textAlign = "left";
	this.charContext.textBaseline = "top";
	this.charContext.fillText(text, offset, 2.5);
}
```
