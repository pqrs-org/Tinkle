import Combine
import MetalKit

@MainActor
final class MetalEffectCoordinator: ObservableObject {
  static let shared = MetalEffectCoordinator()

  let mtkView: MTKView
  private var renderer: MetalEffectRenderer?
  private let effectDidFinishSubject = MetalEffectRenderer.EffectDidFinishSubject()

  var effectDidFinish: AnyPublisher<Void, Never> {
    effectDidFinishSubject.eraseToAnyPublisher()
  }

  @Published var effect = Effect.neonGray.rawValue {
    didSet {
      renderer = MetalEffectRenderer(mtkView: mtkView, effectDidFinish: effectDidFinishSubject)

      renderer?.setEffect(Effect(rawValue: effect))
      renderer?.restart()

      mtkView.delegate = renderer
    }
  }

  init() {
    mtkView = MTKView()
    mtkView.framebufferOnly = false
    mtkView.layer?.isOpaque = false
  }

  func restartEffect() {
    renderer?.setEffect(Effect(rawValue: effect))
    renderer?.restart()
  }
}
