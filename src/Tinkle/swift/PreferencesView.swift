import AppKit
import AXSwift
import SwiftUI

struct PreferencesView: View {
    var window: NSWindow!
    @State var preferencesWindowDelegate = PreferencesWindowDelegate()
    @ObservedObject var userSettings = UserSettings()

    struct GUISize {
        static let buttonIconWidth: CGFloat = 16.0
        static let buttonIconHeight: CGFloat = 16.0
        static let groupBoxPadding = EdgeInsets(top: 5.0,
                                                leading: 10.5,
                                                bottom: 5.0,
                                                trailing: 10.5)
    }

    struct RestartButton: View {
        var body: some View {
            Button(action: { Relauncher.relaunch() })
            {
                Image(decorative: "ic_refresh_18pt")
                    .resizable()
                    .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                Text("Restart Tinkle")
            }
        }
    }

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

    struct OpenAtLoginToggle: View {
        @State private var enabled: Bool = OpenAtLogin.enabled

        var body: some View {
            let binding = Binding<Bool>(
                get: {
                    self.enabled
                },
                set: {
                    self.enabled = $0
                    OpenAtLogin.enabled = $0
                }
            )

            return Toggle(isOn: binding) {
                Text("Open at login")
            }
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
                    Button(action: { NSApplication.shared.terminate(self) })
                    {
                        Image(decorative: "ic_cancel_18pt")
                            .resizable()
                            .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                        Text("Quit Tinkle")
                    }
                    RestartButton()
                }
            }

            if !UIElement.isProcessTrusted() {
                GroupBox(label: Text("User approval is required")) {
                    VStack(alignment: .leading) {
                        Text("User approval for using accessibility features is required.")
                        Text("Tinkle uses the feature to detect the focused window changes.")

                        Spacer(minLength: 20.0)

                        Text("Open System Preferences > Security & Privacy, then turn on Tinkle.")
                        Button(action: { NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!) })
                        {
                            Text("Open System Preferences")
                        }

                        Spacer(minLength: 20.0)

                        Text("Restart Tinkle after you approve the feature.")
                        RestartButton()

                        HStack {
                            Image("accessibility")
                                .resizable()
                                .frame(width: 445.0, height: 382.0)
                            Spacer()
                        }
                    }.padding(GUISize.groupBoxPadding)
                }
            } else {
                GroupBox(label: Text("Configuration")) {
                    VStack(alignment: .leading, spacing: 10.0) {
                        HStack {
                            EffectPicker(selectedEffectRawValue: self.$userSettings.effect)
                            Spacer()
                        }
                        HStack {
                            OpenAtLoginToggle()
                            Spacer()
                        }
                        HStack {
                            Toggle(isOn: self.$userSettings.showMenu) {
                                Text("Show icon in menu bar")
                            }

                            Spacer()
                        }
                    }.padding(GUISize.groupBoxPadding)
                }

                GroupBox(label: Text("Updates")) {
                    HStack {
                        Button(action: { Updater.checkForUpdatesStableOnly() })
                        {
                            Image(decorative: "ic_star_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Check for updates")
                        }

                        Spacer()

                        Button(action: { Updater.checkForUpdatesWithBetaVersion() })
                        {
                            Image(decorative: "ic_star_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Check for beta updates")
                        }
                    }.padding(GUISize.groupBoxPadding)
                }

                GroupBox(label: Text("Web sites")) {
                    HStack(spacing: 20.0) {
                        Button(action: { NSWorkspace.shared.open(URL(string: "https://tinkle.pqrs.org")!) })
                        {
                            Image(decorative: "ic_home_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Open official website")
                        }
                        Button(action: { NSWorkspace.shared.open(URL(string: "https://github.com/pqrs-org/Tinkle")!) })
                        {
                            Image(decorative: "ic_code_18pt")
                                .resizable()
                                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
                            Text("Open GitHub (source code)")
                        }
                        Spacer()
                    }.padding(GUISize.groupBoxPadding)
                }
            }
        }
        .padding(20.0)
    }

    init() {
        userSettings = UserSettings()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 300),
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

struct EffectEntry {
    let name: String
    let value: Effect
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
