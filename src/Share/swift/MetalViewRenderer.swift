import Foundation
import MetalKit

public final class MetalViewRenderer: NSObject, MTKViewDelegate {
  public typealias Callback = () -> Void

  public enum Shader {
    case nop
    case neon
    case shockwave
  }

  private weak var view: MTKView!
  private let callback: Callback
  private let commandQueue: MTLCommandQueue!
  private let device: MTLDevice!
  private let nopCps: MTLComputePipelineState?
  private let shockwaveCps: MTLComputePipelineState?
  private let neonCps: MTLComputePipelineState?
  private var startDate = Date()
  private var shader: Shader = .nop
  private var color = vector_float3(0.0, 0.0, 0.0)

  public init?(mtkView: MTKView, callback: @escaping Callback) {
    view = mtkView
    self.callback = callback
    device = MTLCreateSystemDefaultDevice()!
    commandQueue = device.makeCommandQueue()
    let library = device.makeDefaultLibrary()!

    let nopFunction = library.makeFunction(name: "nopEffect")!
    nopCps = try? device.makeComputePipelineState(function: nopFunction)

    let shockwaveFunction = library.makeFunction(name: "shockwaveEffect")!
    shockwaveCps = try? device.makeComputePipelineState(function: shockwaveFunction)

    let neonFunction = library.makeFunction(name: "neonEffect")!
    neonCps = try? device.makeComputePipelineState(function: neonFunction)

    super.init()
    view.delegate = self
    view.device = device
  }

  public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

  public func draw(in view: MTKView) {
    var time = Float(Date().timeIntervalSince(startDate))

    if time > 0.5 {
      if shader == .nop {
        view.isPaused = true
      } else {
        callback()

        shader = .nop
        restart()

        return
      }
    }

    var cps: MTLComputePipelineState? = nopCps
    switch shader {
    case .nop:
      cps = nopCps
    case .neon:
      cps = neonCps
    case .shockwave:
      cps = shockwaveCps
    }

    if let cps = cps,
      let drawable = view.currentDrawable,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    {
      commandEncoder.setComputePipelineState(cps)
      commandEncoder.setTexture(drawable.texture, index: 0)

      commandEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
      commandEncoder.setBytes(&color, length: MemoryLayout<SIMD3<Float>>.size, index: 1)

      let w = cps.threadExecutionWidth
      let h = cps.maxTotalThreadsPerThreadgroup / w
      let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
      let threadsPerGrid = MTLSize(
        width: drawable.texture.width,
        height: drawable.texture.height,
        depth: 1)
      commandEncoder.dispatchThreads(
        threadsPerGrid,
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

  func setEffect(_ e: Effect?) {
    if e != nil {
      switch e! {
      case .neonGray, .neonLight, .neonDark,
        .neonRed, .neonGreen, .neonBlue:
        shader = .neon
      case .shockwaveGray, .shockwaveLight, .shockwaveDark,
        .shockwaveRed, .shockwaveGreen, .shockwaveBlue:
        shader = .shockwave
      }

      switch e! {
      case .shockwaveRed, .neonRed:
        color = vector_float3(1.0, 0.3, 0.2)
      case .shockwaveGreen, .neonGreen:
        color = vector_float3(0.2, 1.0, 0.2)
      case .shockwaveBlue, .neonBlue:
        color = vector_float3(0.3, 0.2, 1.0)
      case .shockwaveLight, .neonLight:
        color = vector_float3(1.0, 1.0, 1.0)
      case .shockwaveGray, .neonGray:
        color = vector_float3(0.3, 0.3, 0.3)
      case .shockwaveDark, .neonDark:
        color = vector_float3(0.0, 0.0, 0.0)
      }
    } else {
      shader = .nop
    }
  }
}
