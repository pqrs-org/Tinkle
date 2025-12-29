import SwiftUI

struct AccessibilityAlertView: View {
  var body: some View {
    VStack(alignment: .center, spacing: 20.0) {
      Label(
        "User approval for using accessibility features is required.\n"
          + "Tinkle uses the feature to detect the focused window changes.",
        systemImage: "lightbulb"
      )

      Text("Open System Settings > Privacy & Security > Accessibility, then turn on Tinkle.")

      Button(
        action: {
          NSWorkspace.shared.open(
            URL(
              string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        },
        label: {
          Label(
            "Open System Settings > Privacy & Security > Accessibility...",
            systemImage: "arrow.forward.circle.fill")
        })

      Image("accessibility")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 400.0)
        .border(.gray, width: 1)

      Divider()

      Text("Please restart Tinkle after approving it.")

      Button(
        action: { Relauncher.relaunch() },
        label: {
          Label("Restart Tinkle", systemImage: "arrow.clockwise")
        })
    }
    .padding()
    .frame(width: 600)
  }
}
