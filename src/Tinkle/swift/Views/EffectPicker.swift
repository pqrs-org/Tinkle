import SwiftUI

struct EffectPicker: View {
  @Binding var value: String

  struct EffectEntry: Identifiable {
    var id = UUID()
    let name: String
    let value: Effect
    let color: Color
  }

  private let effects: [EffectEntry] = [
    EffectEntry(name: "Shock wave (red)", value: .shockwaveRed, color: Color.red),
    EffectEntry(name: "Shock wave (green)", value: .shockwaveGreen, color: Color.green),
    EffectEntry(name: "Shock wave (blue)", value: .shockwaveBlue, color: Color.blue),
    EffectEntry(name: "Shock wave (light)", value: .shockwaveLight, color: Color.white),
    EffectEntry(name: "Shock wave (gray)", value: .shockwaveGray, color: Color.gray),
    EffectEntry(name: "Shock wave (dark)", value: .shockwaveDark, color: Color.black),
    EffectEntry(name: "Neon (red)", value: .neonRed, color: Color.red),
    EffectEntry(name: "Neon (green)", value: .neonGreen, color: Color.green),
    EffectEntry(name: "Neon (blue)", value: .neonBlue, color: Color.blue),
    EffectEntry(name: "Neon (light)", value: .neonLight, color: Color.white),
    EffectEntry(name: "Neon (gray)", value: .neonGray, color: Color.gray),
    EffectEntry(name: "Neon (dark)", value: .neonDark, color: Color.black),
  ]

  var body: some View {
    Text("value \(value)")

    Picker("Effect", selection: $value) {
      ForEach(effects) { effect in
        (Text("■ ")
          .foregroundColor(effect.color)
          + Text(effect.name))
          .tag(effect.value.rawValue)
      }
      .pickerStyle(.menu)
    }.frame(width: 300.0)
  }
}
