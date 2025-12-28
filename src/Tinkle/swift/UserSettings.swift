import Combine
import Foundation
import SwiftUI

extension Notification.Name {
  static let effectDidChange = Notification.Name("effectDidChange")
}

@MainActor
final class UserSettings: ObservableObject {
  @AppStorage("initialOpenAtLoginRegistered") var initialOpenAtLoginRegistered = false
  @AppStorage("showAdditionalMenuItems") var showAdditionalMenuItems: Bool = false
  @AppStorage("effect") var effect = Effect.neonGray.rawValue {
    didSet {
      NotificationCenter.default.post(name: .effectDidChange, object: effect)
    }
  }
}
