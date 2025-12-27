import MetalKit
import SwiftUI

@main
struct ShaderViewerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Window(
      "Tinkle-ShaderViewerApp",
      id: "main",
      content: {
        ContentView()
      }
    )
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  public func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    true
  }
}
