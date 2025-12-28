import Combine
import Foundation
import SwiftUI

@MainActor
final class UserSettings: ObservableObject {
  @AppStorage("initialOpenAtLoginRegistered") var initialOpenAtLoginRegistered = false
  @AppStorage("showAdditionalMenuItems") var showAdditionalMenuItems: Bool = false
  @AppStorage("effect") var effect = Effect.neonGray.rawValue {
    didSet {
      NotificationCenter.default.post(name: effectDidChange, object: effect)
    }
  }
}
