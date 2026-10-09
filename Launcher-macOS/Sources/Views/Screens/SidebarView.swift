import SwiftUI

struct SidebarView: View {
    @Environment(CrossOverService.self) private var crossOver
    @Binding var selection: ReSkateLauncherApp.Selection

    var body: some View {
        List(selection: $selection) {
            Section {
                Label("Status", systemImage: "antenna.radiowaves.left.and.right")
                    .tag(ReSkateLauncherApp.Selection.status)
                Label("Play", systemImage: "play.circle.fill")
                    .tag(ReSkateLauncherApp.Selection.play)
                Label("Mods", systemImage: "shippingbox")
                    .tag(ReSkateLauncherApp.Selection.mods)
                Label("Log", systemImage: "doc.text.magnifyingglass")
                    .tag(ReSkateLauncherApp.Selection.log)
            }

            Section("Bottle") {
                if let bottle = crossOver.bottle {
                    Label(bottle.name, systemImage: bottle.hasGameInstalled ? "checkmark.seal.fill" : "folder")
                        .badge(bottle.flavor.rawValue)
                } else {
                    Text("`skate-fex` not found")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
        }
        .listStyle(.sidebar)
    }
}
