import SwiftUI

enum TabTag: String {
  case main
  case update
  case action
}

struct SettingsView: View {
  @Binding var showMenuBarExtra: Bool

  @State private var selection = TabTag.main

  var body: some View {
    TabView(selection: $selection) {
      SettingsMainView(showMenuBarExtra: $showMenuBarExtra)
        .tabItem {
          Label("Main", systemImage: "gearshape")
        }
        .tag(TabTag.main)

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
