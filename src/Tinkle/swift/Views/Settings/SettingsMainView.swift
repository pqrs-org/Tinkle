import AXSwift
import SwiftUI

struct SettingsMainView: View {
  @EnvironmentObject private var userSettings: UserSettings

  @Binding var showMenuBarExtra: Bool

  @ObservedObject private var openAtLogin = OpenAtLogin.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 25.0) {
      GroupBox(label: Text("Basic")) {
        VStack(alignment: .leading, spacing: 10.0) {
          Toggle(isOn: $openAtLogin.registered) {
            Text("Open at login")
          }
          .switchToggleStyle()
          .disabled(openAtLogin.developmentBinary)
          .onChange(of: openAtLogin.registered) { value in
            OpenAtLogin.shared.update(register: value)
          }

          if !openAtLogin.error.isEmpty {
            Label(
              openAtLogin.error,
              systemImage: ErrorBorder.icon
            )
            .modifier(ErrorBorder())
          }

          Toggle(isOn: $showMenuBarExtra) {
            Text("Show icon in menu bar")
          }
          .switchToggleStyle()

          Toggle(isOn: $userSettings.showAdditionalMenuItems) {
            Text("Show additional menu items")
          }
          .switchToggleStyle()
          .disabled(!showMenuBarExtra)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      GroupBox(label: Text("Effect")) {
        VStack(alignment: .leading, spacing: 10.0) {
          EffectPicker(value: $userSettings.effect)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
