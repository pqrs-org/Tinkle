import MetalKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?
  var mtkView: MTKView?
  var renderer: MetalViewRenderer?

  func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.disableRelaunchOnLogin()

    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
      styleMask: [
        .titled,
        .closable,
        .miniaturizable,
        .resizable,
        .fullSizeContentView,
      ],
      backing: .buffered,
      defer: false
    )
    window!.title = "Tinkle ShaderViewer"
    window!.contentView = NSHostingView(rootView: ContentView())
    window!.center()
    window!.makeKeyAndOrderFront(self)
  }

  public func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    true
  }
}
