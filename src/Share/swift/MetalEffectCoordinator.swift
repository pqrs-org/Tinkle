import Combine
import MetalKit

@MainActor
final class MetalEffectCoordinator: ObservableObject {
  static let shared = MetalEffectCoordinator()

  let mtkView: MTKView
  private let renderer: MetalEffectRenderer
  private let effectDidFinishSubject = MetalEffectRenderer.EffectDidFinishSubject()

  var effectDidFinish: AnyPublisher<Void, Never> {
    effectDidFinishSubject.eraseToAnyPublisher()
  }

  @Published var effect = Effect.neonGray.rawValue {
    didSet {
      renderer.setEffect(Effect(rawValue: effect))
    }
  }

  init() {
    mtkView = MTKView()
    mtkView.framebufferOnly = false
    mtkView.layer?.isOpaque = false

    renderer = MetalEffectRenderer(mtkView: mtkView, effectDidFinish: effectDidFinishSubject)
    mtkView.delegate = renderer
  }

  func restartEffect() {
    renderer.setEffect(Effect(rawValue: effect))
    renderer.restart()
  }
}
