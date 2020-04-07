import Combine
import Foundation

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("effect", defaultValue: Effect.shockwaveBlue.rawValue)
    var effect: String

    @UserDefault("showMenu", defaultValue: true)
    var showMenu: Bool {
        willSet {
            objectWillChange.send()
        }
        didSet {
            NotificationCenter.default.post(
                name: Notification.Name("ShowMenuSettingChanged"),
                object: nil
            )
        }
    }
}
