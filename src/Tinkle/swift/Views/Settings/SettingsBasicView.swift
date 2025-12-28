import AXSwift
import SwiftUI

struct SettingsBasicView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @Binding var showMenuBarExtra: Bool

  @ObservedObject private var openAtLogin = OpenAtLogin.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Basic")) {
        VStack(alignment: .leading, spacing: 10.0) {
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

          Toggle(isOn: $showMenuBarExtra) {
            Text("Show icon in menu bar")
          }
          .switchToggleStyle()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Effect")) {
        VStack(alignment: .leading, spacing: 10.0) {
          EffectPicker(value: $userSettings.effect)
        }
        .padding()
      }

      Spacer()
    }.padding()
  }
}
