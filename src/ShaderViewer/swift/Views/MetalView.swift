import MetalKit
import SwiftUI

struct MetalView: NSViewRepresentable {
  func makeNSView(context _: Context) -> MTKView {
    return Renderer.shared.mtkView
  }

  func updateNSView(_: MTKView, context _: Context) {}
}
