import MetalKit
import SwiftUI

@main
struct ShaderViewerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Window(
      "Tinkle-ShaderViewer",
      id: "main",
      content: {
        ShaderViewerContentView()
      }
    )
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  public func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    true
  }
}
