import SwiftUI

struct ContentView: View {
  @ObservedObject private var renderer = MetalEffectViewModel.shared
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

      EffectPicker(value: $renderer.effect)

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
      renderer.effect = Effect.shockwaveGray.rawValue
    }
  }
}
