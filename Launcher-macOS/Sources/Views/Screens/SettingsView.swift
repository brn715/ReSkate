import SwiftUI

struct SettingsView: View {
    @Environment(CrossOverService.self) private var crossOver

    var body: some View {
        Form {
            Section("CrossOver") {
                ForEach(crossOver.installs) { install in
                    LabeledContent(install.flavor.rawValue, value: install.bundleURL.path)
                        .font(.callout)
                }
            }
            Section {
                Button("Re-scan bottles") {
                    crossOver.rescan()
                }
            }
        }
        .padding()
        .frame(width: 480)
    }
}
