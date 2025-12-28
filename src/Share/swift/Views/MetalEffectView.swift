import MetalKit
import SwiftUI

struct MetalEffectView: NSViewRepresentable {
  func makeNSView(context _: Context) -> MTKView {
    return MetalEffectCoordinator.shared.mtkView
  }

  func updateNSView(_: MTKView, context _: Context) {}
}
