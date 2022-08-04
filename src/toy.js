function setup(gl) {
  gl.clearColor(0.0, 0.0, 0.0, 0.0);
}

function main() {
  const canvas = document.querySelector("#glCanvas");
  const gl = canvas.getContext("webgl");

  if (gl === null) {
    return;
  }

  setup(gl);

  function resizeCanvasToDisplaySize(canvas) {
    // Lookup the size the browser is displaying the canvas in CSS pixels.
    const displayWidth  = window.screen.width;
    const displayHeight = window.screen.height;

    // Check if the canvas is not the same size.
    const needResize = canvas.width  !== displayWidth ||
                       canvas.height !== displayHeight;

    if (needResize) {
      // Make the canvas the same size
      canvas.width  = displayWidth;
      canvas.height = displayHeight;
    }

    return needResize;
  }

  requestAnimationFrame(draw);
  function draw() {
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    resizeCanvasToDisplaySize(gl.canvas);

    requestAnimationFrame(draw);
  }
}

export default main;
