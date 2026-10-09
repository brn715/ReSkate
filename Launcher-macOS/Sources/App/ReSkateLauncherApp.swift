import SwiftUI

@main
struct ReSkateLauncherApp: App {
    @State private var crossOver = CrossOverService()
    @State private var selection: Selection = .status

    enum Selection: Hashable {
        case status
        case play
        case mods
        case log
    }

    var body: some Scene {
        WindowGroup {
            RootView(selection: $selection)
                .environment(crossOver)
                .frame(minWidth: 860, minHeight: 560)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1080, height: 700)

        Settings {
            SettingsView()
                .environment(crossOver)
        }
    }
}
