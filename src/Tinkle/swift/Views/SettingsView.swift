import SwiftUI

enum TabTag: String {
  case basic
  case update
  case action
}

struct SettingsView: View {
  @State private var selection = TabTag.basic

  var body: some View {
    TabView(selection: $selection) {
      SettingsBasicView()
        .tabItem {
          Label("Main", systemImage: "gearshape")
        }
        .tag(TabTag.basic)

      SettingsUpdateView()
        .tabItem {
          Label("Update", systemImage: "network")
        }
        .tag(TabTag.update)

      SettingsActionView()
        .tabItem {
          Label("Quit, Restart", systemImage: "bolt.circle")
        }
        .tag(TabTag.action)
    }
    .scenePadding()
    .frame(width: 600)
  }
}
