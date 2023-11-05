import Foundation
import MetalKit
import PlaygroundSupport
import SwiftUI

let source = """
  #include <metal_stdlib>
  using namespace metal;

  namespace {
      float circle(float2 uv, float r, float blur)
      {
          float d = length(uv);
          float c = smoothstep(r, r - blur, d);
          return c;
      }
  }

  kernel void effect(texture2d<float, access::write> o[[texture(0)]],
                     constant float &time[[buffer(0)]],
                     constant float3 &color[[buffer(1)]],
                     ushort2 gid[[thread_position_in_grid]])
  {
      float width = o.get_width();
      float height = o.get_height();

      float2 p = float2(gid) / float2(width, height);
      p -= 0.5;
      p.x *= min(width / height, 1.0);
      p.y *= min(height / width, 1.0);

      float speed = 4.0;
      float r = time * speed + 0.6;
      float ir = clamp(1.0 - speed * time, 0.9, 1.0);

      float c1 = circle(p, r, 0.4);
      float c2 = circle(p, r, ir);
      float shade = c1 - c2;
      float3 c = color * shade;

      float alpha = min(shade, 0.5);
      // float alpha = min(max(max(c[0], c[1]), c[2]), 0.5);

      o.write(float4(c, alpha), gid);
  }
  """

@available(macOS 11.0, *)
public class MetalViewRenderer: NSObject, MTKViewDelegate {
  weak var view: MTKView!
  let commandQueue: MTLCommandQueue!
  let device: MTLDevice!
  var cps: MTLComputePipelineState?
  var texture: MTLTexture?
  private var startDate: Date = Date()
  private var color: vector_float3 = vector_float3(0.3, 0.2, 1.0)  // rgb
  public init?(mtkView: MTKView) {
    view = mtkView
    device = MTLCreateSystemDefaultDevice()!
    commandQueue = device.makeCommandQueue()
    if let library = try? device.makeLibrary(source: source, options: nil) {
      if let function = library.makeFunction(name: "effect") {
        cps = try? device.makeComputePipelineState(function: function)
      }
    }

    super.init()
    view.delegate = self
    view.device = device
    view.colorPixelFormat = .bgra8Unorm
  }

  public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

  public func draw(in view: MTKView) {
    var time = Float(Date().timeIntervalSince(startDate))

    if time > 0.5 {
      startDate = Date()
    }

    // Resize texture
    if let drawable = view.currentDrawable {
      if drawable.texture.width != texture?.width || drawable.texture.height != texture?.height {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
          pixelFormat: .rgba32Float, width: drawable.texture.width, height: drawable.texture.height,
          mipmapped: false)
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        texture = device!.makeTexture(descriptor: textureDescriptor)
      }
    }

    // Draw

    if let cps = cps,
      let texture = texture,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    {
      commandEncoder.setComputePipelineState(cps)
      commandEncoder.setTexture(texture, index: 0)

      commandEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
      commandEncoder.setBytes(&color, length: MemoryLayout<SIMD3<Float>>.size, index: 1)

      let w = cps.threadExecutionWidth
      let h = cps.maxTotalThreadsPerThreadgroup / w
      let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
      let threadsPerGrid = MTLSize(
        width: texture.width,
        height: texture.height,
        depth: 1)
      commandEncoder.dispatchThreads(
        threadsPerGrid,
        threadsPerThreadgroup: threadsPerThreadgroup)
      commandEncoder.endEncoding()

      commandBuffer.commit()
      commandBuffer.waitUntilCompleted()
    }

    // Blit

    if let texture = texture,
      let drawable = view.currentDrawable,
      let commandBuffer = commandQueue.makeCommandBuffer()
    {
      let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
      blitEncoder.copy(
        from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
        sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1),
        to: drawable.texture, destinationSlice: 0, destinationLevel: 0,
        destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
      blitEncoder.endEncoding()
      commandBuffer.present(drawable)
      commandBuffer.commit()
    }
  }

  func setColor(_ c: vector_float3) {
    color = c
  }
}

struct RepresentedMTKView: NSViewRepresentable {
  let view: MTKView

  func makeNSView(context _: Context) -> MTKView {
    return view
  }

  func updateNSView(_: MTKView, context _: Context) {}
}

let view = MTKView()
view.layer?.isOpaque = false
let delegate = MetalViewRenderer(mtkView: view)
view.delegate = delegate
// PlaygroundPage.current.liveView = view

struct ContentView: View {
  var body: some View {
    VStack {
      Text("SwiftUI + Metal")

      RepresentedMTKView(view: view).frame(
        minWidth: 200,
        minHeight: 400
      )

      Divider()

      VStack {
        Text("Choose effect color")
        HStack {
          Button(
            action: {
              delegate?.setColor(vector_float3(1.0, 0.3, 0.2))
            },
            label: {
              Text("Red")
            })
          Button(
            action: {
              delegate?.setColor(vector_float3(0.2, 1.0, 0.3))
            },
            label: {
              Text("Green")
            })
          Button(
            action: {
              delegate?.setColor(vector_float3(0.3, 0.2, 1.0))
            },
            label: {
              Text("Blue")
            })
          Button(
            action: {
              delegate?.setColor(vector_float3(1.0, 1.0, 1.0))
            },
            label: {
              Text("Light")
            })
          Button(
            action: {
              delegate?.setColor(vector_float3(0.0, 0.0, 0.0))
            },
            label: {
              Text("Dark")
            })
        }
      }
    }
  }
}

PlaygroundPage.current.setLiveView(ContentView())
