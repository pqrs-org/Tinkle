import Combine
import Foundation

final class UserSettings: ObservableObject {
  static let shared = UserSettings()
  static let effectSettingChanged = Notification.Name("EffectSettingChanged")
  static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")

  @UserDefault("effect", defaultValue: Effect.shockwaveBlue.rawValue)
  var effect: String {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.effectSettingChanged,
        object: nil
      )
    }
  }

  @Published var openAtLogin = OpenAtLogin.enabled {
    didSet {
      OpenAtLogin.enabled = openAtLogin
    }
  }

  @UserDefault("showMenu", defaultValue: true)
  var showMenu: Bool {
    willSet {
      objectWillChange.send()
    }
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.showMenuSettingChanged,
        object: nil
      )
    }
  }
}
