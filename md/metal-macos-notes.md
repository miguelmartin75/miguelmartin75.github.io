---
title: Metal & MacOS Notes
---

# Resources
- https://dev.to/javiersalcedopuyo/tutorial-metal-hellotriangle-using-swift-5-and-no-xcode-i72
- https://medium.com/@shoheiyokoyama/rendering-graphics-content-using-the-metalkit-framework-ea3503f34535
# Basics
## Handling Input #todo 

## [MTKView](https://developer.apple.com/documentation/metalkit/mtkview?language=objc)

"Default implementation of a Metal-aware view that can be used to render graphcis using metal"

## The Delegate
The Metal API uses the delegate pattern for drawing.

`MTKViewDelegate`
- `draw` => asked to render
- `mtkView` => on resize

### When Metal Draws

By default metal is timer based and will tell you when to draw. `isPaused` and `enableSetNeedsDisplay` set to false.

Draw by calling `setNeedsDisplay()`. `isPaused` and `enableSetNeedsDisplay` both need to be set to true.

Call `draw()` explicitly
- isPaused must be set to true and enableSetNeedsDisplay must be set to false

## Commands and Client/Server
Metal works can be compared to client/server pattern
  - Metal app is the client, GPU is the server
  - Requests are sent commands. GPU notifies when it's ready for more work.
  - Command performs drawing, parrallel computation or resource management
### Protocols for Commands
- Three types: Queue, Buffer and Encoder
- `MTLCommand<type>` where `<type>` is the above
- Create these objects from the device object

Relationship
- Queue -> Create Buffer
- Encoder -> Add comands to buffer
- Buffer is enqueued onto the queue
- Queues send buffers to the GPU and the GPU executes the command

### CommandQueue
- Thread-safe object
- Allows multiple command buffers to be encoded at the same time
  - Create one or more command queues when your app is initialized
  - Keep them throughout the lifetime of your app

```swift
let commandQueue = device.makeCommandQueue()
```

### CommandBuffer
Stores commands for the GPU to execute.

Example usage:

```swift
let commandBuffer = queue.makeCommandBuffer()
commandBuffer.commit()
```

### CommandEncoder

Encodes commands to be added to the CommandBuffer.

Lightweight objects every-time you want to send commands to the GPU.

Different types of command encoders. Each provides a different set of commands that can be encoded.

- [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder): for graphics rendering
- [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder): for computation
- [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder): for memory management
- [MTLParrallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder): multiple graphics rendering tasks to be encoded in parallel

## Pipeline
### MTLPipelineDescriptor
Describes:
- shaders
- pixel format to use, etc.

### MTLPipelineState
- Construct one with a device and a descriptor object
- When constructed:
  - Compiles shaders, etc.

## How to Render
GPU saves result in a [texture](https://developer.apple.com/documentation/quartzcore/cametaldrawable/1478159-texture).

Get this texture from

1. Create/end render pass
2. Present drawable to the screen
3. Commit the command buffer

### Step 1 - Create Render Pass
- Instance of a pass descriptor and command encoder
- pass descriptor defines:
  - dpi
  - width/height
  - stencil buffer
  - etc.

```swift
let commandBuffer = queue.makeCommandBuffer()
let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
```

Can use the view's renderPassDescriptor instead. `view.currentRenderPassDescriptor`.

### Step 2 - Present

```swift
commandBuffer.present(view.currentDrawable!)
```

### Step 3 - Commit

```swift
commandBuffer.commit()
```
