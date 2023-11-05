import SwiftUI

struct AccessibilityAlertView: View {
  var body: some View {
    HStack(alignment: .top, spacing: 20.0) {
      VStack(alignment: .leading) {
        Text("User approval for using accessibility features is required.")
        Text("Tinkle uses the feature to detect the focused window changes.")

        Text("Open System Settings > Privacy & Security > Accessibility, then turn on Tinkle.")
          .padding(
            .top, 20.0)
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

        Text("Restart Tinkle after you approve the feature.").padding(.top, 20.0)

        Button(
          action: { Relauncher.relaunch() },
          label: {
            Label("Restart Tinkle", systemImage: "arrow.clockwise")
          })

        Spacer()
          .frame(height: 50.0)

        Divider()

        Button(
          action: { NSApplication.shared.terminate(self) },
          label: {
            Label("Quit Tinkle", systemImage: "xmark.circle.fill")
          })
      }.frame(minWidth: 400.0)

      Image("accessibility")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 400.0)
        .border(.gray, width: 1)
    }.padding()
  }
}

struct AccessibilityAlertView_Previews: PreviewProvider {
  static var previews: some View {
    AccessibilityAlertView()
      .previewLayout(.sizeThatFits)
  }
}
