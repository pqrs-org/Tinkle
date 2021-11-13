import AXSwift
import SwiftUI

class PreferencesWindowManager: NSObject {
    static let shared = PreferencesWindowManager()

    private var window: NSWindow?
    private var closed = false

    func show() {
        if window != nil, !closed {
            window!.makeKeyAndOrderFront(self)
            return
        }

        window = NSWindow(
            contentRect: .zero,
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )

        window!.isReleasedWhenClosed = false
        window!.title = "Tinkle Preferences"
        if !UIElement.isProcessTrusted() {
            window!.contentView = NSHostingView(rootView: AccessibilityAlertView())
        } else {
            window!.contentView = NSHostingView(rootView: PreferencesView())
        }
        window!.delegate = self
        window!.center()
    }
}

extension PreferencesWindowManager: NSWindowDelegate {
    func windowWillClose(_: Notification) {
        closed = true
    }
}
