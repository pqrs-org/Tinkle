import AXSwift
import MetalKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var mtkView: MTKView?
    var renderer: MetalViewRenderer?
    var observers: [pid_t: Observer] = [:]
    var focusedWindowObserver: FocusedWindowObserver?
    var preferencesWindowManager: PreferencesWindowManager?
    var axStatusChecker: AXStatusChecker!
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_: Notification) {
        NSApplication.shared.disableRelaunchOnLogin()

        Updater.checkForUpdatesInBackground()

        axStatusChecker = AXStatusChecker()

        //
        // Setup menu
        //

        showMenu()

        NotificationCenter.default.addObserver(
            forName: UserSettings.showMenuSettingChanged,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            self.showMenu()
        }

        //
        // Check AX
        //

        if !UIElement.isProcessTrusted(withPrompt: true) {
            print("user approval is required")
            return
        }

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
                self.runEffect()
            } else {
                self.hide()
            }
        })

        NotificationCenter.default.addObserver(
            forName: UserSettings.effectSettingChanged,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            self.runEffect()
        }
    }

    func applicationShouldHandleReopen(_: NSApplication,
                                       hasVisibleWindows _: Bool) -> Bool
    {
        showPreferences(sender: self)
        return true
    }

    func runEffect() {
        window?.makeKeyAndOrderFront(self)
        renderer?.setEffect(Effect(rawValue: UserSettings.shared.effect))
        renderer?.restart()
    }

    func showMenu() {
        if statusBarItem == nil, UserSettings.shared.showMenu {
            statusBarItem = NSStatusBar.system.statusItem(
                withLength: NSStatusItem.squareLength
            )
            statusBarItem?.button?.image = NSImage(named: "menu")

            let menu = NSMenu(title: "Tinkle")

            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
            menu.addItem(
                withTitle: "Tinkle " + version,
                action: nil,
                keyEquivalent: ""
            )

            menu.addItem(NSMenuItem.separator())

            menu.addItem(
                withTitle: "Preferences...",
                action: #selector(showPreferences),
                keyEquivalent: ""
            )

            menu.addItem(NSMenuItem.separator())

            menu.addItem(
                withTitle: "Quit Tinkle",
                action: #selector(NSApplication.shared.terminate),
                keyEquivalent: ""
            )

            statusBarItem?.menu = menu
        }

        //
        // Set visibility
        //

        statusBarItem?.isVisible = UserSettings.shared.showMenu
    }

    @objc func showPreferences(sender _: AnyObject?) {
        if preferencesWindowManager == nil || preferencesWindowManager!.closed {
            preferencesWindowManager = PreferencesWindowManager()
        }
        preferencesWindowManager!.show()

        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        if window != nil {
            window!.orderOut(window!)
        }
    }
}
