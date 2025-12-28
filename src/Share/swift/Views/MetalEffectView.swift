import MetalKit
import SwiftUI

struct MetalEffectView: NSViewRepresentable {
  let effectCoordinator: MetalEffectCoordinator

  func makeNSView(context _: Context) -> MTKView {
    return effectCoordinator.mtkView
  }

  func updateNSView(_: MTKView, context _: Context) {}
}
