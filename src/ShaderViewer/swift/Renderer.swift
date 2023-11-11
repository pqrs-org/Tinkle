import Combine
import MetalKit

final class Renderer: ObservableObject {
  static let shared = Renderer()

  let mtkView: MTKView
  private var renderer: MetalViewRenderer?

  @Published var effect = Effect.neonGray.rawValue {
    didSet {
      renderer = MetalViewRenderer(mtkView: mtkView) {
        Task { @MainActor in
          try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)

          self.renderer?.setEffect(Effect(rawValue: self.effect))
          self.renderer?.restart()
        }
      }

      renderer?.setEffect(Effect(rawValue: effect))
      renderer?.restart()

      mtkView.delegate = Renderer.shared.renderer
    }
  }

  init() {
    mtkView = MTKView()
    mtkView.framebufferOnly = false
    mtkView.layer?.isOpaque = false
  }
}
