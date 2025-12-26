import Combine
import Foundation
import SwiftUI

final class UserSettings: ObservableObject {
  static let shared = UserSettings()
  static let effectSettingChanged = Notification.Name("EffectSettingChanged")
  static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")

  //
  // Initial Open At Login
  //

  @AppStorage("initialOpenAtLoginRegistered") var initialOpenAtLoginRegistered = false

  @AppStorage("effect") var effect = Effect.neonGray.rawValue {
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.effectSettingChanged,
        object: nil
      )
    }
  }

  @AppStorage("showMenu") var showMenu = true {
    didSet {
      NotificationCenter.default.post(
        name: UserSettings.showMenuSettingChanged,
        object: nil
      )
    }
  }
}
