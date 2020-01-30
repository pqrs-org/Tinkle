import Foundation

final class UserSettings: ObservableObject {
    @UserDefault("effect", defaultValue: "shockwave")
    var effect: String

    @UserDefault("color", defaultValue: "blue")
    var color: String
}
