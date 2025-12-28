import Combine
import MetalKit

@MainActor
final class MetalEffectCoordinator: ObservableObject {
  let mtkView: MTKView
  private let renderer: MetalEffectRenderer
  private let effectDidFinishSubject = MetalEffectRenderer.EffectDidFinishSubject()

  var effectDidFinish: AnyPublisher<Void, Never> {
    effectDidFinishSubject.eraseToAnyPublisher()
  }

  init() {
    mtkView = MTKView()
    mtkView.framebufferOnly = false
    mtkView.layer?.isOpaque = false

    renderer = MetalEffectRenderer(mtkView: mtkView, effectDidFinish: effectDidFinishSubject)
    mtkView.delegate = renderer
  }

  func startEffect(_ effect: Effect?) {
    renderer.setEffect(effect ?? .neonGray)
    renderer.restart()
  }
}
