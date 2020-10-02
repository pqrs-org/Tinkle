import AppKit
import AXSwift
import SwiftUI

struct PreferencesView: View {
    var window: NSWindow!
    private var accessibilityAlertWindow: NSWindow?
    @State var preferencesWindowDelegate = PreferencesWindowDelegate()
    @ObservedObject var userSettings = UserSettings.shared

    struct EffectPicker: View {
        @Binding var selectedEffectRawValue: String
        @State private var selectedIndex: Int = -1

        let effects: [EffectEntry] = [
            EffectEntry(name: "Shock wave (red)", value: .shockwaveRed),
            EffectEntry(name: "Shock wave (green)", value: .shockwaveGreen),
            EffectEntry(name: "Shock wave (blue)", value: .shockwaveBlue),
            EffectEntry(name: "Neon (red)", value: .neonRed),
            EffectEntry(name: "Neon (green)", value: .neonGreen),
            EffectEntry(name: "Neon (blue)", value: .neonBlue),
        ]

        var body: some View {
            let binding = Binding<Int>(
                get: {
                    if self.selectedIndex < 0 {
                        for (index, e) in self.effects.enumerated() {
                            if e.value.rawValue == self.selectedEffectRawValue {
                                return index
                            }
                        }

                        return 0
                    }

                    return self.selectedIndex
                },
                set: {
                    self.selectedIndex = $0
                    self.selectedEffectRawValue = self.effects[$0].value.rawValue
                }
            )

            return Picker(selection: binding, label: Text("Effect")) {
                ForEach(0 ..< effects.count) {
                    Text(self.effects[$0].name)
                }
            }.frame(width: 300.0)
        }
    }

    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

    var body: some View {
        VStack(alignment: .leading, spacing: 25.0) {
            HStack {
                Image(decorative: "logo").resizable().frame(width: 64.0, height: 64.0)
                Text("Tinkle version " + self.version)

                Spacer()

                VStack(alignment: .trailing) {
                    Button(action: { NSApplication.shared.terminate(self) }) {
                        Image(decorative: "ic_cancel_18pt")
                            .resizable()
                            .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                        Text("Quit Tinkle")
                    }
                    RestartButton()
                }
            }

            GroupBox(label: Text("Configuration")) {
                HStack {
                    VStack(alignment: .leading, spacing: 10.0) {
                        EffectPicker(selectedEffectRawValue: self.$userSettings.effect)
                        Toggle(isOn: self.$userSettings.openAtLogin) {
                            Text("Open at login")
                        }
                        Toggle(isOn: self.$userSettings.showMenu) {
                            Text("Show icon in menu bar")
                        }
                    }
                    Spacer()
                }
                .padding()
            }

            #if USE_SPARKLE
                GroupBox(label: Text("Updates")) {
                    HStack {
                        Button(action: { Updater.checkForUpdatesStableOnly() }) {
                            Image(decorative: "ic_star_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Check for updates")
                        }

                        Spacer()

                        Button(action: { Updater.checkForUpdatesWithBetaVersion() }) {
                            Image(decorative: "ic_star_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Check for beta updates")
                        }
                    }.padding()
                }
            #endif

            GroupBox(label: Text("Web sites")) {
                HStack(spacing: 20.0) {
                    Button(action: { NSWorkspace.shared.open(URL(string: "https://tinkle.pqrs.org")!) }) {
                        Image(decorative: "ic_home_18pt")
                            .resizable()
                            .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                        Text("Open official website")
                    }
                    Button(action: { NSWorkspace.shared.open(URL(string: "https://github.com/pqrs-org/Tinkle")!) }) {
                        Image(decorative: "ic_code_18pt")
                            .resizable()
                            .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                        Text("Open GitHub (source code)")
                    }
                    Spacer()
                }.padding()
            }
        }
        .padding()
        .frame(width: 600.0)
    }

    init() {
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

        preferencesWindowDelegate.window = window

        window.title = "Tinkle Preferences"
        window.contentView = NSHostingView(rootView: self)
        window.delegate = preferencesWindowDelegate
        window.center()

        preferencesWindowDelegate.windowIsOpen = true
        window.makeKeyAndOrderFront(nil)

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
            accessibilityAlertWindow!.centerToOtherWindow(window)

            window.addChildWindow(accessibilityAlertWindow!, ordered: .above)
            accessibilityAlertWindow!.makeKeyAndOrderFront(nil)
        }
    }

    class PreferencesWindowDelegate: NSObject, NSWindowDelegate {
        var window: NSWindow?
        var windowIsOpen = false

        func windowWillClose(_: Notification) {
            windowIsOpen = false

            window?.childWindows?.forEach {
                window?.removeChildWindow($0)
                $0.close()
            }
        }
    }
}

struct EffectEntry {
    let name: String
    let value: Effect
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .previewLayout(.sizeThatFits)
    }
}
