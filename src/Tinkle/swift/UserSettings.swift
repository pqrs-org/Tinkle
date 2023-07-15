import Combine
import Foundation

final class UserSettings: ObservableObject {
  static let shared = UserSettings()
  static let effectSettingChanged = Notification.Name("EffectSettingChanged")
  static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")

  //
  // Initial Open At Login
  //

  @UserDefault("initialOpenAtLoginRegistered", defaultValue: false)
  var initialOpenAtLoginRegistered: Bool {
    willSet {
      objectWillChange.send()
    }
  }

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
