import AXSwift
import AppKit
import SwiftUI

struct PreferencesView: View {
  @ObservedObject private var userSettings = UserSettings.shared
  @ObservedObject private var openAtLogin = OpenAtLogin.shared
  @ObservedObject private var updater = Updater.shared

  struct EffectPicker: View {
    @Binding var selectedEffectRawValue: String
    @State private var selectedIndex: Int = -1

    struct EffectEntry {
      let name: String
      let value: Effect
      let color: Color
    }

    let effects: [EffectEntry] = [
      EffectEntry(name: "Shock wave (red)", value: .shockwaveRed, color: Color.red),
      EffectEntry(name: "Shock wave (green)", value: .shockwaveGreen, color: Color.green),
      EffectEntry(name: "Shock wave (blue)", value: .shockwaveBlue, color: Color.blue),
      EffectEntry(name: "Shock wave (light)", value: .shockwaveLight, color: Color.white),
      EffectEntry(name: "Shock wave (gray)", value: .shockwaveGray, color: Color.gray),
      EffectEntry(name: "Shock wave (dark)", value: .shockwaveDark, color: Color.black),
      EffectEntry(name: "Neon (red)", value: .neonRed, color: Color.red),
      EffectEntry(name: "Neon (green)", value: .neonGreen, color: Color.green),
      EffectEntry(name: "Neon (blue)", value: .neonBlue, color: Color.blue),
      EffectEntry(name: "Neon (light)", value: .neonLight, color: Color.white),
      EffectEntry(name: "Neon (gray)", value: .neonGray, color: Color.gray),
      EffectEntry(name: "Neon (dark)", value: .neonDark, color: Color.black),
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
        ForEach(0..<effects.count) {
          Text("■ ")
            .foregroundColor(self.effects[$0].color)
            + Text(self.effects[$0].name)
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
          QuitButton()
          RestartButton()
        }
      }

      GroupBox(label: Text("Configuration")) {
        HStack {
          VStack(alignment: .leading, spacing: 10.0) {
            EffectPicker(selectedEffectRawValue: self.$userSettings.effect)

            HStack {
              Toggle(isOn: $openAtLogin.registered) {
                Text("Open at login")
              }
              .switchToggleStyle()
              .disabled(openAtLogin.developmentBinary)
              .onChange(of: openAtLogin.registered) { value in
                OpenAtLogin.shared.update(register: value)
              }

              Spacer()
            }

            if openAtLogin.error.count > 0 {
              VStack {
                Label(
                  openAtLogin.error,
                  systemImage: "exclamationmark.circle.fill"
                )
                .padding()
              }
              .foregroundColor(Color.errorForeground)
              .background(Color.errorBackground)
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
            Button(action: { updater.checkForUpdatesStableOnly() }) {
              Label("Check for updates", systemImage: "star")
            }
            .disabled(!updater.canCheckForUpdates)

            Spacer()

            Button(action: { updater.checkForUpdatesWithBetaVersion() }) {
              Label("Check for beta updates", systemImage: "star.circle")
            }
            .disabled(!updater.canCheckForUpdates)
          }.padding()
        }
      #endif

      GroupBox(label: Text("Web sites")) {
        HStack(spacing: 20.0) {
          Button(action: { NSWorkspace.shared.open(URL(string: "https://tinkle.pqrs.org")!) }) {
            Label("Open official website", systemImage: "house")
          }
          Button(action: {
            NSWorkspace.shared.open(URL(string: "https://github.com/pqrs-org/Tinkle")!)
          }) {
            Label("Open GitHub (source code)", systemImage: "network")
          }
          Spacer()
        }.padding()
      }
    }
    .padding()
    .frame(width: 600.0)
  }
}

struct PreferencesView_Previews: PreviewProvider {
  static var previews: some View {
    PreferencesView()
      .previewLayout(.sizeThatFits)
  }
}
