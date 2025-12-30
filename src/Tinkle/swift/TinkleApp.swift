import AXSwift
import Combine
import MetalKit
import OSLog
import SettingsAccess
import SwiftUI

@main
struct TinkleApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @StateObject private var userSettings: UserSettings
  @StateObject private var recentApplications: RecentApplicationsStore

  // Since passing a property of an ObservableObject to MenuBarExtra.isInserted causes a notification loop, the flag must be an independent variable.
  @AppStorage("showMenu") var showMenuBarExtra = true

  private let version =
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

  init() {
    //
    // Initialize properties
    //

    let userSettings = UserSettings()
    _userSettings = StateObject(wrappedValue: userSettings)

    let recentApplications = RecentApplicationsStore()
    _recentApplications = StateObject(wrappedValue: recentApplications)

    appDelegate.userSettings = userSettings
    appDelegate.recentApplications = recentApplications

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

    _ = UIElement.isProcessTrusted(withPrompt: true)
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

        Label("Recent apps", systemImage: "waveform.path.ecg")

        ForEach(recentApplications.items, id: \.processIdentifier) { item in
          Button(
            action: {
              _ = item.activate(options: [.activateIgnoringOtherApps])
            },
            label: {
              Label {
                Text(
                  verbatim:
                    "\((item.localizedName ?? item.bundleIdentifier ?? "Unknown App").paddedRight(to: 30)) pid:\(item.processIdentifier)"
                )
                // Since HStack and similar layouts can't be used in MenuBarExtra,
                // the only way to align the pid is to use a fixed-width font.
                .font(.system(.callout, design: .monospaced))
              } icon: {
                Image("clear")
              }
            }
          )
          .disabled(item.isTerminated)
        }

        Divider()

        Button(
          action: {
            NSApp.terminate(nil)
          },
          label: {
            Label("Quit Tinkle", systemImage: "xmark.rectangle")
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
      if !UIElement.isProcessTrusted() {
        AccessibilityAlertView()
      } else {
        SettingsView(showMenuBarExtra: $showMenuBarExtra)
          .environmentObject(userSettings)
      }
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var mainWindowController: MainWindowController?
  var userSettings: UserSettings?
  var recentApplications: RecentApplicationsStore?

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let userSettings = userSettings,
      let recentApplications = recentApplications
    else {
      return
    }

    mainWindowController = MainWindowController(
      userSettings: userSettings,
      recentApplications: recentApplications)
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
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown",
    category: String(describing: MainWindowController.self))
  private var focusedWindowObserver: FocusedWindowObserver?
  private var cancellables: Set<AnyCancellable> = []
  private let effectCoordinator = MetalEffectCoordinator()
  private let recentApplications: RecentApplicationsStore

  init(userSettings: UserSettings, recentApplications: RecentApplicationsStore) {
    self.recentApplications = recentApplications

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

    focusedWindowObserver = FocusedWindowObserver(
      callback: { (frame: CGRect, runningApplication: NSRunningApplication) in
        self.recentApplications.insert(runningApplication)

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

    NotificationCenter.default.publisher(for: effectDidChange)
      .sink { [weak self] notification in
        guard let self else { return }
        guard let effect = notification.object as? String else { return }
        self.window?.orderFront(self)
        self.effectCoordinator.startEffect(Effect(rawValue: effect))
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: effectWindowShouldHide)
      .sink { [weak self] _ in
        guard let self else { return }

        self.logger.info("effectWindowShouldHide")

        self.window?.orderOut(self)
      }
      .store(in: &cancellables)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

@MainActor
final class RecentApplicationsStore: ObservableObject {
  @Published private(set) var items: [NSRunningApplication] = []

  func insert(_ item: NSRunningApplication) {
    items.removeAll { $0.processIdentifier == item.processIdentifier }
    items.insert(item, at: 0)

    if items.count > 10 {
      items.removeLast(items.count - 10)
    }
  }
}

extension String {
  fileprivate func paddedRight(to width: Int) -> String {
    if count >= width {
      return String(prefix(width))
    }
    return self + String(repeating: " ", count: width - count)
  }
}
