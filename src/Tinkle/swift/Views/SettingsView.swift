import SwiftUI

enum NavigationTag: String {
  case basic
  case update
  case action
}

struct SettingsView: View {
  @State private var selection: NavigationTag = NavigationTag.basic

  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Group {
            Button(action: {
              selection = .basic
            }) {
              SidebarLabelView(text: "Basic", systemImage: "gearshape")
            }
            .sidebarButtonStyle(selected: selection == .basic)

            Button(action: {
              selection = .update
            }) {
              SidebarLabelView(text: "Update", systemImage: "network")
            }
            .sidebarButtonStyle(selected: selection == .update)
          }

          Divider()
            .padding(.vertical, 10.0)

          Group {
            Button(action: {
              selection = .action
            }) {
              SidebarLabelView(text: "Quit, Restart", systemImage: "bolt.circle")
            }
            .sidebarButtonStyle(selected: selection == .action)
          }

          Spacer()
        }
        .frame(width: 200)

        Divider()

        switch selection {
        case .basic:
          SettingsBasicView()
        case .update:
          SettingsUpdateView()
        case .action:
          SettingsActionView()
        }
      }
    }.frame(width: 900, height: 550)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewLayout(.sizeThatFits)
  }
}
