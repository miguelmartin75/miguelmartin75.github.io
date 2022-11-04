---
title: Metal & MacOS Notes
---

** [MTKView](https://developer.apple.com/documentation/metalkit/mtkview?language=objc)

"Default implementation of a Metal-aware view that can be used to render graphcis using metal"

*** The Delegate
The Metal API uses the delegate pattern for drawing.

`MTKViewDelegate`
- draw => asked to render
- mtkView => on resize

**** When Metal Draws

By default metal is timer based and will tell you when to draw. `isPaused` and `enableSetNeedsDisplay` set to false.

Draw by calling `setNeedsDisplay()`. `isPaused` and `enableSetNeedsDisplay` both need to be set to true.

Call `draw()` explicitly
- isPaused must be set to true and enableSetNeedsDisplay must be set to false

** Commands and Client/Server
Metal works can be compared to client/server pattern
  - Metal app is the client, GPU is the server
  - Requests are sent commands. GPU notifies when it's ready for more work.
  - Command performs drawing, parrallel computation or resource management
*** Protocols for Commands
- Three types: Queue, Buffer and Encoder
- `MTLCommand<type>` where `<type>` is the above
- Create these objects from the device object

Relationship
- Queue -> Create Buffer
- Encoder -> Add comands to buffer
- Buffer is enqueued onto the queue
- Queues send buffers to the GPU and the GPU executes the command

**** CommandQueue
- Thread-safe object
- Allows multiple command buffers to be encoded at the same time
  - Create one or more command queues when your app is initialized
  - Keep them throughout the lifetime of your app

#+begin_src swift
let commandQueue = device.makeCommandQueue()
#+end_src

**** CommandBuffer
Stores commands for the GPU to execute.

Example usage:

#+begin_src swift
let commandBuffer = queue.makeCommandBuffer()
commandBuffer.commit()
#+end_src

**** CommandEncoder

Encodes commands to be added to the CommandBuffer.

Lightweigh objects everytime you want to send commands to the GPU.

Different types of command encoders. Each provides a different set of commands that can be encoded.

- [[https://developer.apple.com/documentation/metal/mtlcomputecommandencoder][MTLRenderCommandEncoder]]: for graphics rendering
- [[https://developer.apple.com/documentation/metal/mtlrendercommandencoder][MTLComputeCommandEncoder]]: for computation
- [[https://developer.apple.com/documentation/metal/mtlblitcommandencoder][MTLBlitCommandEncoder]]: for memory management
- [[https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder][MTLParrallelRenderCommandEncoder]]: multiple graphics rendering tasks to be encoded in parrallel

** Pipeline
*** MTLPipelineDescriptor
Describes:
- shaders
- pixel format to use, etc.

*** MTLPipelineState
- Construct one with a device and a descriptor object
- When constructed:
  - Compiles shaders, etc.

** How to Render
GPU saves result in a [[https://developer.apple.com/documentation/quartzcore/cametaldrawable/1478159-texture][texture]].

Get this texture from

1. Create/end render pass
2. Present drawable to the screen
3. Commit the command buffer

*** Step 1 - Create Render Pass
- Instance of a pass descriptor and command encoder
- pass descriptor defines:
  - dpi
  - width/height
  - stencil buffer
  - etc.

#+begin_src swift
let commandBuffer = queue.makeCommandBuffer()
let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
#+end_src

Can use the view's renderPassDescriptor instead. `view.currentRenderPassDescriptor`.

*** Step 2 - Present

#+begin_src swift
commandBuffer.present(view.currentDrawable!)
#+end_src

*** Step 3 - Commit

#+begin_src swift
commandBuffer.commit()
#+end_src

** Handling Input

** Commands and Client/Server
Metal works can be compared to client/server pattern
  - Metal app is the client, GPU is the server
  - Requests are sent commands. GPU notifies when it's ready for more work.
  - Command performs drawing, parrallel computation or resource management
*** Protocols for Commands
- Three types: Queue, Buffer and Encoder
- `MTLCommand<type>` where `<type>` is the above
- Create these objects from the device object

Relationship
- Queue -> Create Buffer
- Encoder -> Add comands to buffer
- Buffer is enqueued onto the queue
- Queues send buffers to the GPU and the GPU executes the command

**** CommandQueue
- Thread-safe object
- Allows multiple command buffers to be encoded at the same time
  - Create one or more command queues when your app is initialized
  - Keep them throughout the lifetime of your app

#+begin_src swift
let commandQueue = device.makeCommandQueue()
#+end_src

**** CommandBuffer
Stores commands for the GPU to execute.

Example usage:

#+begin_src swift
let commandBuffer = queue.makeCommandBuffer()
commandBuffer.commit()
#+end_src

**** CommandEncoder

Encodes commands to be added to the CommandBuffer.

Lightweigh objects everytime you want to send commands to the GPU.

Different types of command encoders. Each provides a different set of commands that can be encoded.

- [[https://developer.apple.com/documentation/metal/mtlcomputecommandencoder][MTLRenderCommandEncoder]]: for graphics rendering
- [[https://developer.apple.com/documentation/metal/mtlrendercommandencoder][MTLComputeCommandEncoder]]: for computation
- [[https://developer.apple.com/documentation/metal/mtlblitcommandencoder][MTLBlitCommandEncoder]]: for memory management
- [[https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder][MTLParrallelRenderCommandEncoder]]: multiple graphics rendering tasks to be encoded in parrallel

** Pipeline
*** MTLPipelineDescriptor
Describes:
- shaders
- pixel format to use, etc.

*** MTLPipelineState
- Construct one with a device and a descriptor object
- When constructed:
  - Compiles shaders, etc.

** How to Render
GPU saves result in a [[https://developer.apple.com/documentation/quartzcore/cametaldrawable/1478159-texture][texture]].

Get this texture from

1. Create/end render pass
2. Present drawable to the screen
3. Commit the command buffer

*** Step 1 - Create Render Pass
- Instance of a pass descriptor and command encoder
- pass descriptor defines:
  - dpi
  - width/height
  - stencil buffer
  - etc.

#+begin_src swift
let commandBuffer = queue.makeCommandBuffer()
let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
#+end_src

Can use the view's renderPassDescriptor instead. `view.currentRenderPassDescriptor`.

*** Step 2 - Present

#+begin_src swift
commandBuffer.present(view.currentDrawable!)
#+end_src

*** Step 3 - Commit

#+begin_src swift
commandBuffer.commit()
#+end_src

** Handling Input

* Resources
- https://dev.to/javiersalcedopuyo/tutorial-metal-hellotriangle-using-swift-5-and-no-xcode-i72
- https://medium.com/@shoheiyokoyama/rendering-graphics-content-using-the-metalkit-framework-ea3503f34535

* Rendering Text
Let's keep it simple. Organize the code later.

What do we want to do? Start:
1. Render a blob of text
2. Render embedded images
3. Render embedded videos

I can render in an MTKView right now. We need a glyph cache.

** Features
Graphics
- Textured canvas
- Textured text

Text
- Auto-complete
- Fuzzy finding
  - Can be accomplished with fzf or similar
- Remote connection

** Algorithm
x = 0
y = 0
for each line:
    for each ch in line
        glyph = get_glyph(ch)
        x += glyth.width
        y +=

** How to get Glyths?

