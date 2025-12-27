import AXSwift
import MetalKit
import SettingsAccess
import SwiftUI

@main
struct TinkleApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @StateObject private var userSettings: UserSettings

  // Since passing a property of an ObservableObject to MenuBarExtra.isInserted causes a notification loop, the flag must be an independent variable.
  @AppStorage("showMenu") var showMenuBarExtra = true

  private let version =
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

  var window: NSWindow?
  var mtkView: MTKView?
  var renderer: MetalViewRenderer?
  var observers: [pid_t: Observer] = [:]
  var focusedWindowObserver: FocusedWindowObserver?
  var axStatusChecker: AXStatusChecker!

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()

    _userSettings = StateObject(wrappedValue: userSettings)

    //
    // Register OpenAtLogin
    //

    if !OpenAtLogin.shared.developmentBinary {
      if !userSettings.initialOpenAtLoginRegistered {
        OpenAtLogin.shared.update(register: true)
        userSettings.initialOpenAtLoginRegistered = true
      }
    }

    //
    // Additional setups
    //

    NSApplication.shared.disableRelaunchOnLogin()

    Updater.shared.checkForUpdatesInBackground()

    axStatusChecker = AXStatusChecker()

    //
    // Check AX
    //

    if !UIElement.isProcessTrusted(withPrompt: true) {
      print("user approval is required")
      return
    }

    //     mtkView = MTKView()
    //     mtkView!.framebufferOnly = false
    //     mtkView!.layer?.isOpaque = false
    //
    //     renderer = MetalViewRenderer(mtkView: mtkView!) {
    //       self.hide()
    //     }
    //     mtkView!.delegate = renderer!
    //
    //     window = NSWindow(
    //       contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
    //       styleMask: [
    //         .borderless,
    //         .fullSizeContentView,
    //       ],
    //       backing: .buffered,
    //       defer: false
    //     )
    //     window!.backgroundColor = NSColor.clear
    //     window!.hasShadow = false
    //     window!.ignoresMouseEvents = true
    //     window!.collectionBehavior = [.transient, .ignoresCycle]
    //     window!.isOpaque = false
    //     window!.level = .statusBar
    //     window!.contentView = mtkView
    //
    //     focusedWindowObserver = FocusedWindowObserver(callback: { (frame: CGRect) in
    //       if frame.width > 0 {
    //         self.window?.setFrame(frame, display: true)
    //         self.runEffect()
    //       } else {
    //         self.hide()
    //       }
    //     })
    //
    //     NotificationCenter.default.addObserver(
    //       forName: UserSettings.effectSettingChanged,
    //       object: nil,
    //       queue: OperationQueue.main
    //     ) { _ in
    //       self.runEffect()
    //     }
  }

  var body: some Scene {
    MenuBarExtra(
      isInserted: $showMenuBarExtra,
      content: {
        Text("Tinkle \(version)")

        Divider()

        SettingsLink {
          Label("Settings...", systemImage: "gear")
            .labelStyle(.titleAndIcon)
        } preAction: {
          NSApp.activate(ignoringOtherApps: true)
        } postAction: {
        }

        Button(
          action: {
            NSApp.activate(ignoringOtherApps: true)
            Updater.shared.checkForUpdatesStableOnly()
          },
          label: {
            Label("Check for updates...", systemImage: "network")
              .labelStyle(.titleAndIcon)
          }
        )

        if userSettings.showAdditionalMenuItems {
          Button(
            action: {
              NSApp.activate(ignoringOtherApps: true)
              Updater.shared.checkForUpdatesWithBetaVersion()
            },
            label: {
              Label("Check for beta updates...", systemImage: "hare")
                .labelStyle(.titleAndIcon)
            }
          )
        }

        Divider()

        Button(
          action: {
            NSApp.terminate(nil)
          },
          label: {
            Label("Quit ShowyEdge", systemImage: "xmark.rectangle")
              .labelStyle(.titleAndIcon)
          }
        )
      },
      label: {
        Label(
          title: { Text("Tinkle") },
          icon: {
            // To prevent the menu icon from appearing blurry, it is necessary to explicitly set the displayScale.
            Image("menu")
              .environment(\.displayScale, 2.0)
          }
        )
      }
    )

    Settings {
      SettingsView(showMenuBarExtra: $showMenuBarExtra)
        .environmentObject(userSettings)
    }
  }

  func runEffect() {
    //    window?.makeKeyAndOrderFront(self)
    //    renderer?.setEffect(Effect(rawValue: UserSettings.shared.effect))
    //    renderer?.restart()
  }

  func hide() {
    //    if window != nil {
    //      window!.orderOut(window!)
    //    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var userSettings: UserSettings?

  func applicationDidFinishLaunching(_ notification: Notification) {
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    NotificationCenter.default.post(
      name: openSettingsNotification,
      object: nil,
      userInfo: nil)
    return true
  }
}
