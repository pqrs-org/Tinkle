import Foundation
import SwiftUI

struct ShaderViewerContentView: View {
  @StateObject private var coordinator = MetalEffectCoordinator()
  @State private var color = Color.gray
  @State private var effect = Effect.shockwaveGreen.rawValue
  @State private var backgroundColor = Color.gray

  var body: some View {
    VStack {
      MetalEffectView(effectCoordinator: coordinator)
        .background(backgroundColor)
        .frame(minWidth: 400, minHeight: 200)
        .border(Color.white)
        .padding()

      Divider()

      EffectPicker(value: $effect)

      HStack {
        Text("Background color:")

        Button(action: { backgroundColor = Color.white }, label: { Text("White") })
        Button(action: { backgroundColor = Color.black }, label: { Text("Black") })
        Button(action: { backgroundColor = Color.gray }, label: { Text("Gray") })
        Button(action: { backgroundColor = Color.red }, label: { Text("Red") })
        Button(action: { backgroundColor = Color.green }, label: { Text("Green") })
        Button(action: { backgroundColor = Color.blue }, label: { Text("Blue") })
      }
    }
    .padding()
    .onAppear {
      coordinator.startEffect(Effect(rawValue: effect))
    }
    .onReceive(coordinator.effectDidFinish) { _ in
      Task { @MainActor in
        try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
        coordinator.startEffect(Effect(rawValue: effect))
      }
    }
  }
}
