import SwiftUI

struct AccessibilityAlertView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 20.0) {
            VStack(alignment: .leading) {
                Text("User approval for using accessibility features is required.")
                Text("Tinkle uses the feature to detect the focused window changes.")

                Text("Open System Preferences > Security & Privacy, then turn on Tinkle.").padding(.top, 20.0)
                Button(action: { NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!) }) {
                    Label("Open Security & Privacy System Preferences...", systemImage: "arrow.forward.circle.fill")
                }

                Text("Restart Tinkle after you approve the feature.").padding(.top, 20.0)
                RestartButton()
            }.frame(minWidth: 400.0)

            Image("accessibility")
                .resizable()
                .frame(width: 334.0, height: 286.0)
                .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
        }.padding()
    }
}

struct AccessibilityAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityAlertView()
            .previewLayout(.sizeThatFits)
    }
}
