import AppKit
import AXSwift
import SwiftUI

struct PreferencesView: View {
    @State var preferencesWindowDelegate = PreferencesWindowDelegate()

    let userApproved: String = UIElement.isProcessTrusted() ?
        "Accessibility features are approved." :
        "User approval for using accessibility features is required."

    var body: some View {
        Text(userApproved)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var window: NSWindow!
    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
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
        window.center()
        window.title = "Tinkle Preferences"
        window.contentView = NSHostingView(rootView: self)
        window.delegate = preferencesWindowDelegate
        preferencesWindowDelegate.windowIsOpen = true
        window.makeKeyAndOrderFront(nil)
    }

    class PreferencesWindowDelegate: NSObject, NSWindowDelegate {
        var windowIsOpen = false

        func windowWillClose(_: Notification) {
            windowIsOpen = false
        }
    }
}