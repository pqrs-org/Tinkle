import AXSwift
import Combine
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
  private let axStatusChecker = AXStatusChecker()

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()

    _userSettings = StateObject(wrappedValue: userSettings)

    appDelegate.userSettings = userSettings

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

    //
    // Check AX
    //

    if !UIElement.isProcessTrusted(withPrompt: true) {
      print("user approval is required")
      return
    }
  }

  var body: some Scene {
    // The main window is manually managed by MainWindowController.

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
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var mainWindowController: MainWindowController?
  var userSettings: UserSettings?

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let userSettings = userSettings else { return }

    mainWindowController = MainWindowController(userSettings: userSettings)
    mainWindowController?.showWindow(nil)
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

class MainWindowController: NSWindowController, NSWindowDelegate {
  private var focusedWindowObserver: FocusedWindowObserver?
  private var cancellables: Set<AnyCancellable> = []
  private let effectCoordinator = MetalEffectCoordinator()

  init(userSettings: UserSettings) {
    // Note:
    // On macOS 13, the only way to remove the title bar is to manually create an NSWindow like this.
    //
    // The following methods do not work properly:
    // - .windowStyle(.hiddenTitleBar) does not remove the window frame.
    // - NSApp.windows.first.styleMask = [.borderless] causes the app to crash.

    let w = NSWindow(
      // MetalEffectView must be initialized with a non-zero size, so we set an arbitrary initial size.
      contentRect: .init(x: 0, y: 0, width: 200, height: 100),
      styleMask: [
        .borderless,
        .fullSizeContentView,
      ],
      backing: .buffered,
      defer: false
    )

    // Note: Do not set alpha value for window.
    // Window with alpha value causes glitch at switching a space (Mission Control).

    w.backgroundColor = .clear
    // w.backgroundColor = .blue
    w.isOpaque = false
    w.hasShadow = false
    w.ignoresMouseEvents = true
    w.level = .statusBar
    w.collectionBehavior.insert(.transient)
    w.collectionBehavior.insert(.ignoresCycle)
    w.contentView = NSHostingView(
      rootView: ContentView(coordinator: effectCoordinator)
        .openSettingsAccess()
    )

    super.init(window: w)

    w.delegate = self

    //
    // Setup FocusedWindowObserver
    //

    focusedWindowObserver = FocusedWindowObserver(callback: { (frame: CGRect) in
      if frame.width > 0 {
        self.window?.setFrame(frame, display: true)
        self.window?.orderFront(self)
        self.effectCoordinator.startEffect(Effect(rawValue: userSettings.effect))
      } else {
        self.window?.orderOut(self)
      }
    })

    effectCoordinator.effectDidFinish
      .sink { [weak self] in
        self?.window?.orderOut(nil)
      }
      .store(in: &cancellables)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
