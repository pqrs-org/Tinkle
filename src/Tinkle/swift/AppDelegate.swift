import AXSwift
import Cocoa
import MetalKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var mtkView: MTKView?
    var renderer: MetalViewRenderer?
    var observers: [pid_t: Observer] = [:]
    var focusedWindowObserver: FocusedWindowObserver?
    var preferencesView: PreferencesView?
    var userSettings: UserSettings?

    func applicationDidFinishLaunching(_: Notification) {
        if !UIElement.isProcessTrusted(withPrompt: true) {
            print("user approval is required")
            return

        } else {
            userSettings = UserSettings()

            mtkView = MTKView()
            mtkView!.framebufferOnly = false
            mtkView!.layer?.isOpaque = false

            renderer = MetalViewRenderer(mtkView: mtkView!) {
                self.hide()
            }
            mtkView!.delegate = renderer!

            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
                styleMask: [.borderless,
                            .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window!.backgroundColor = NSColor.clear
            window!.hasShadow = false
            window!.ignoresMouseEvents = true
            window!.collectionBehavior = [.transient, .ignoresCycle]
            window!.isOpaque = false
            window!.level = .statusBar
            window!.contentView = mtkView

            focusedWindowObserver = FocusedWindowObserver(callback: { (frame: CGRect) in
                if frame.width > 0 {
                    self.window?.setFrame(frame, display: true)
                    self.window?.makeKeyAndOrderFront(self)
                    if self.userSettings != nil {
                        self.renderer?.setEffect(Effect(rawValue: self.userSettings!.effect))
                    }
                    self.renderer?.restart()
                } else {
                    self.hide()
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

    func hide() {
        // If MTKView.delegate is enabled and the window is removed from the screen list,
        // macOS kill the app after 6 minutes into launch.
        // So, we have to display a small window to avoid it.

        window?.setFrame(CGRect(x: 0, y: 0, width: 16, height: 16), display: true)
        renderer?.setEffect(nil)
        renderer?.restart()
    }
}
