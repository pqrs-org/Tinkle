import Foundation
import SwiftUI

struct ContentView: View {
  @ObservedObject private var coordinator = MetalEffectCoordinator.shared
  @ObservedObject private var settings = Settings.shared
  @State private var color = Color.gray

  var body: some View {
    VStack {
      MetalEffectView()
        .background(settings.backgroundColor)
        .frame(minWidth: 400, minHeight: 200)
        .border(Color.white)
        .padding()

      Divider()

      EffectPicker(value: $coordinator.effect)

      Divider()

      HStack {
        Text("Background color:")

        Button(action: { settings.backgroundColor = Color.white }, label: { Text("White") })
        Button(action: { settings.backgroundColor = Color.black }, label: { Text("Black") })
        Button(action: { settings.backgroundColor = Color.gray }, label: { Text("Gray") })
        Button(action: { settings.backgroundColor = Color.red }, label: { Text("Red") })
        Button(action: { settings.backgroundColor = Color.green }, label: { Text("Green") })
        Button(action: { settings.backgroundColor = Color.blue }, label: { Text("Blue") })
      }
    }
    .padding()
    .onAppear {
      coordinator.effect = Effect.shockwaveBlue.rawValue
    }
    .onReceive(coordinator.effectDidFinish) { _ in
      Task { @MainActor in
        try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
        coordinator.restartEffect()
      }
    }
  }
}
