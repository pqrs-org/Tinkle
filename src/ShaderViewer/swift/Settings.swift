import SwiftUI

final class Settings: ObservableObject {
  static let shared = Settings()

  @Published var backgroundColor = Color.black
}
