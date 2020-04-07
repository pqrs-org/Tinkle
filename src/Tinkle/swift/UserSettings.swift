import Combine
import Foundation

final class UserSettings: ObservableObject {
    static let showMenuSettingChanged = Notification.Name("ShowMenuSettingChanged")

    @UserDefault("effect", defaultValue: Effect.shockwaveBlue.rawValue)
    var effect: String

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
