import Foundation
import SettingsAccess
import SwiftUI

struct ContentView: View {
  @Environment(\.openSettingsLegacy) var openSettingsLegacy

  var body: some View {
    VStack {
      MetalEffectView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .onReceive(NotificationCenter.default.publisher(for: openSettingsNotification)) { _ in
      Task { @MainActor in
        try? openSettingsLegacy()
      }
    }
  }
}
