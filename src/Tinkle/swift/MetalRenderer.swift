import Foundation
import MetalKit

public final class MetalViewRenderer: NSObject, MTKViewDelegate {
    public typealias Callback = () -> Void

    private weak var view: MTKView!
    private let callback: Callback
    private let commandQueue: MTLCommandQueue!
    private let device: MTLDevice!
    private let cps: MTLComputePipelineState!
    private var startDate: Date = Date()
    private var color: vector_float3 = vector_float3(0.3, 0.2, 1.0) // rgb

    public init?(mtkView: MTKView, callback: @escaping Callback) {
        view = mtkView
        self.callback = callback
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()!
        let function = library.makeFunction(name: "focusedWindowChangedEffect")!
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