import Combine
import MetalKit

@MainActor
final class MetalEffectViewModel: ObservableObject {
  static let shared = MetalEffectViewModel()

  let mtkView: MTKView
  private var renderer: MetalEffectRenderer?

  @Published var effect = Effect.neonGray.rawValue {
    didSet {
      renderer = MetalEffectRenderer(mtkView: mtkView) {
        Task { @MainActor in
          try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)

          self.renderer?.setEffect(Effect(rawValue: self.effect))
          self.renderer?.restart()
        }
      }

      renderer?.setEffect(Effect(rawValue: effect))
      renderer?.restart()

      mtkView.delegate = MetalEffectViewModel.shared.renderer
    }
  }

  init() {
    mtkView = MTKView()
    mtkView.framebufferOnly = false
    mtkView.layer?.isOpaque = false
  }
}
