import SwiftUI

struct RestartButton: View {
  var body: some View {
    Button(action: { Relauncher.relaunch() }) {
      Label("Restart Tinkle", systemImage: "arrow.clockwise")
    }
  }
}
