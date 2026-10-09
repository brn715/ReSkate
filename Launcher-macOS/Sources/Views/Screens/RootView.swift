import SwiftUI

struct RootView: View {
    @Environment(CrossOverService.self) private var crossOver
    @Binding var selection: ReSkateLauncherApp.Selection

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            switch selection {
            case .status: StatusView()
            case .play:   PlayView()
            case .mods:   ModsView()
            case .log:    LogView()
            }
        }
        .navigationTitle("ReSkate")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                BottlePickerView()
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    crossOver.rescan()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .help("Re-scan CrossOver bottles")
            }
        }
        .task {
            crossOver.rescan()
        }
    }
}

#Preview {
    RootView(selection: .constant(.status))
        .environment(CrossOverService())
}
