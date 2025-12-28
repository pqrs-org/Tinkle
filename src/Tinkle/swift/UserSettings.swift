import Combine
import Foundation
import SwiftUI

@MainActor
final class UserSettings: ObservableObject {
  static let shared = UserSettings()

  @AppStorage("initialOpenAtLoginRegistered") var initialOpenAtLoginRegistered = false
  @AppStorage("showAdditionalMenuItems") var showAdditionalMenuItems: Bool = false

  @AppStorage("effect") var effect = Effect.neonGray.rawValue {
    didSet {
      MetalEffectCoordinator.shared.effect = effect
    }
  }

  init() {
    MetalEffectCoordinator.shared.effect = effect
  }
}
