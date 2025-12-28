import MetalKit
import SwiftUI

struct MetalEffectView: NSViewRepresentable {
  func makeNSView(context _: Context) -> MTKView {
    return MetalEffectViewModel.shared.mtkView
  }

  func updateNSView(_: MTKView, context _: Context) {}
}
