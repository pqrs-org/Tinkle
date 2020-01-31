import Foundation

final class UserSettings: ObservableObject {
    @UserDefault("effect", defaultValue: Effect.shockwaveBlue.rawValue)
    var effect: String
}
