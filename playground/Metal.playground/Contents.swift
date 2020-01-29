import Foundation
import MetalKit
import PlaygroundSupport
import SwiftUI

let source = """
#include <metal_stdlib>
using namespace metal;

namespace {
float line(float2 start, float2 end, float2 uv)
{
    float2 line = end - start;
    float frac = dot(uv - start, line) / dot(line, line);
    return distance(start + line * clamp(frac, 0.0, 1.0), uv);
}
}

kernel void effect(texture2d<float, access::write> o[[texture(0)]],
                   constant float &time[[buffer(0)]],
                   constant float3 &color[[buffer(1)]],
                   ushort2 gid[[thread_position_in_grid]])
{
    float width = o.get_width();
    float height = o.get_height();

    float2 uv = float2(gid) / float2(width, height);
    uv -= 0.5;

    float box = 1.0;
    // top
    box = min(box, line(float2(-0.48, 0.48), float2(0.48, 0.48), uv));
    // bottom
    box = min(box, line(float2(-0.48, -0.48), float2(0.48, -0.48), uv));
    // left
    box = min(box, line(float2(-0.48, -0.48), float2(-0.48, 0.48), uv));
    // right
    box = min(box, line(float2(0.48, -0.48), float2(0.48, 0.48), uv));

    float shade = 0.01 * (1.0 - time * 2.0) / max(0.0001, box - 0.0002);
    
    float3 c = color * shade;

    float alpha = min(max(max(c[0], c[1]), c[2]), 0.5 - time * 2.0);

    o.write(float4(c, alpha), gid);
}
"""

public class MetalViewRenderer: NSObject, MTKViewDelegate {
    weak var view: MTKView!
    let commandQueue: MTLCommandQueue!
    let device: MTLDevice!
    let cps: MTLComputePipelineState!
    private var startDate: Date = Date()
    private var color: vector_float3 = vector_float3(0.3, 0.2, 1.0) // rgb
    public init?(mtkView: MTKView) {
        view = mtkView
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()
        let library = try! device.makeLibrary(source: source, options: nil)
        let function = library.makeFunction(name: "effect")!
        cps = try! device.makeComputePipelineState(function: function)
        
        super.init()
        view.delegate = self
        view.device = device
    }
    
    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
    
    public func draw(in view: MTKView) {
        var time = Float(Date().timeIntervalSince(startDate))
        
        if time > 1.0 {
            view.isPaused = true
        }
        
        if let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(cps)
            commandEncoder.setTexture(drawable.texture, index: 0)

            commandEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
            commandEncoder.setBytes(&color, length: MemoryLayout<SIMD3<Float>>.size, index: 1)

            let w = cps.threadExecutionWidth
            let h = cps.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
            let threadsPerGrid = MTLSize(width: drawable.texture.width,
                                         height: drawable.texture.height,
                                         depth: 1)
            commandEncoder.dispatchThreads(threadsPerGrid,
                                           threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    func restart() {
        startDate = Date()
        view.isPaused = false
    }
    
    func setColor(_ c: vector_float3) {
        color = c
        restart()
    }
}

struct RepresentedMTKView: NSViewRepresentable {
    let view : MTKView;
    
    func makeNSView(context: Context) -> MTKView {
        return view
    }
    
    func updateNSView(_ view: MTKView, context: Context) {
    }
}

let view = MTKView()
view.layer?.isOpaque = false
let delegate = MetalViewRenderer(mtkView: view)
view.delegate = delegate
//PlaygroundPage.current.liveView = view

struct ContentView: View {
    var body: some View {
        VStack {
            Text("SwiftUI + Metal")
            
            RepresentedMTKView(view: view).frame(
                minWidth: 200,
                minHeight: 200
            )

            Divider()

            VStack {
                Text("Choose effect color")
                HStack {
                    Button(action:{
                        delegate?.setColor(vector_float3(1.0, 0.3, 0.2))
                    }) {
                        Text("Red")
                    }
                    Button(action:{
                        delegate?.setColor(vector_float3(0.2, 1.0, 0.3))
                    }) {
                        Text("Green")
                    }
                    Button(action:{
                        delegate?.setColor(vector_float3(0.3, 0.2, 1.0))
                    }) {
                        Text("Blue")
                    }
                }
            }
            
            Divider()

            Button(action:{
                delegate?.restart()
            }) {
                Text("Restart")
            }
        }
    }
}
PlaygroundPage.current.setLiveView(ContentView())
