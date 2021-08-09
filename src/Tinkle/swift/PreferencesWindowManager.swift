import AXSwift
import SwiftUI

class PreferencesWindowManager: NSObject {
    static let shared = PreferencesWindowManager()

    private var preferencesWindow: NSWindow?
    private var accessibilityAlertWindow: NSWindow?
    private var closed = false

    func show() {
        if preferencesWindow != nil, !closed {
            preferencesWindow!.makeKeyAndOrderFront(self)
            return
        }

        preferencesWindow = NSWindow(
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

        preferencesWindow!.isReleasedWhenClosed = false
        preferencesWindow!.title = "Tinkle Preferences"
        preferencesWindow!.contentView = NSHostingView(rootView: PreferencesView())
        preferencesWindow!.delegate = self
        preferencesWindow!.center()

        preferencesWindow!.makeKeyAndOrderFront(nil)

        if !UIElement.isProcessTrusted() {
            accessibilityAlertWindow = NSPanel(
                contentRect: .zero,
                styleMask: [
                    .titled,
                    .closable,
                    .fullSizeContentView,
                ],
                backing: .buffered,
                defer: false
            )
            accessibilityAlertWindow!.title = "Accessibilit Alert"
            accessibilityAlertWindow!.contentView = NSHostingView(rootView: AccessibilityAlertView())
            accessibilityAlertWindow!.centerToOtherWindow(preferencesWindow!)

            preferencesWindow!.addChildWindow(accessibilityAlertWindow!, ordered: .above)
            accessibilityAlertWindow!.makeKeyAndOrderFront(nil)
        }
    }
}

extension PreferencesWindowManager: NSWindowDelegate {
    func windowWillClose(_: Notification) {
        closed = true
    }
}
