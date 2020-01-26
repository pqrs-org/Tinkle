import MetalKit
import SwiftUI

struct RepresentedMTKView: NSViewRepresentable {
    let view: MTKView

    func makeNSView(context _: Context) -> MTKView {
        return view
    }

    func updateNSView(_: MTKView, context _: Context) {}
}
