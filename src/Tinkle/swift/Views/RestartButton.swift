import SwiftUI

struct RestartButton: View {
    var body: some View {
        Button(action: { Relauncher.relaunch() }) {
            Image(decorative: "ic_refresh_18pt")
                .resizable()
                .frame(width: GUISize.buttonIconWidth, height: GUISize.buttonIconHeight)
            Text("Restart Tinkle")
        }
    }
}
