import AppKit
import AXSwift
import SwiftUI

struct PreferencesView: View {
    var window: NSWindow!
    @State var preferencesWindowDelegate = PreferencesWindowDelegate()
    @ObservedObject var userSettings = UserSettings()

    let userApproved: String = UIElement.isProcessTrusted() ?
        "Accessibility features are approved." :
        "User approval for using accessibility features is required."

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
                    } else {
                        return self.selectedIndex
                    }
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
            }
        }
    }

    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(decorative: "logo").resizable().frame(width: 64.0, height: 64.0)
                Text("Tinkle version " + self.version)

                Spacer()

                Button(action: { NSApplication.shared.terminate(self) }) {
                    Image(decorative: "ic_cancel_18pt")
                        .resizable()
                        .frame(width: 16.0, height: 16.0)
                    Text("Quit Tinkle")
                }
            }

            Text(self.userApproved)

            Spacer()

            Form {
                Section {
                    EffectPicker(selectedEffectRawValue: self.$userSettings.effect)
                        .frame(width: 300.0)
                }
            }

            Spacer()
        }
        .padding(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
    }

    init() {
        userSettings = UserSettings()

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

struct EffectEntry {
    let name: String
    let value: Effect
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView().frame(width: 400.0, height: 300.0)
    }
}
