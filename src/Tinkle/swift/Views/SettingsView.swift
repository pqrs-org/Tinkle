import SwiftUI

enum TabTag: String {
  case basic
  case update
  case action
}

struct SettingsView: View {
  @Binding var showMenuBarExtra: Bool

  @State private var selection = TabTag.basic

  var body: some View {
    TabView(selection: $selection) {
      SettingsBasicView(showMenuBarExtra: $showMenuBarExtra)
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
          Label("Quit, Restart", systemImage: "xmark.rectangle")
        }
        .tag(TabTag.action)
    }
    .scenePadding()
    .frame(width: 600)
  }
}
