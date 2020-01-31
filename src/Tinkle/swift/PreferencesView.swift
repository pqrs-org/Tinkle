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
        @State private var selectedIndex: Int = 0

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
                    for (index, e) in self.effects.enumerated() {
                        if e.value.rawValue == self.selectedEffectRawValue {
                            return index
                        }
                    }
                    return 0
                },
                set: {
                    self.selectedIndex = $0
                    self.selectedEffectRawValue = self.effects[self.selectedIndex].value.rawValue
                }
            )

            return Picker(selection: binding, label: Text("Effect")) {
                ForEach(0 ..< effects.count) {
                    Text(self.effects[$0].name)
                }
            }
        }
    }

    var body: some View {
        VStack {
            Text(userApproved)

            Spacer()

            Form {
                Section {
                    EffectPicker(selectedEffectRawValue: $userSettings.effect)
                }
            }

            Spacer()
        }.padding(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
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
