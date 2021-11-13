import SwiftUI

struct QuitButton: View {
    var body: some View {
        Button(action: { NSApplication.shared.terminate(self) }) {
            Label("Quit Tinkle", systemImage: "xmark.circle.fill")
        }
    }
}
