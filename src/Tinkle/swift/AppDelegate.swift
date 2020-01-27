import AXSwift
import Cocoa
import MetalKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var observers: [pid_t: Observer] = [:]
    var focusedWindowObserver: FocusedWindowObserver!
    var preferencesView: PreferencesView?

    func applicationDidFinishLaunching(_: Notification) {
        if !UIElement.isProcessTrusted(withPrompt: true) {
            print("user approval is required")
            showPreferences()

        } else {
            let view = MTKView()
            view.framebufferOnly = false
            view.layer?.isOpaque = false
            let renderer = MetalViewRenderer(mtkView: view) {
                self.window.orderOut(self.window)
            }
            view.delegate = renderer

            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
                styleMask: [.borderless,
                            .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.backgroundColor = NSColor.clear
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.transient, .ignoresCycle]
            window.isOpaque = false
            window.level = .statusBar
            window.contentView = view

            focusedWindowObserver = FocusedWindowObserver(callback: { (frame: CGRect) in
                if frame.width > 0 {
                    self.window.setFrame(frame, display: true)
                    self.window.makeKeyAndOrderFront(self)
                    renderer?.restart()
                } else {
                    self.window.orderOut(self.window)
                }
        })
        }
    }

    func applicationShouldHandleReopen(_: NSApplication,
                                       hasVisibleWindows _: Bool) -> Bool {
        showPreferences()
        return true
    }

    func showPreferences() {
        if let preferencesView = preferencesView, preferencesView.preferencesWindowDelegate.windowIsOpen {
            preferencesView.window.makeKeyAndOrderFront(self)
        } else {
            preferencesView = PreferencesView()
        }
    }
}
