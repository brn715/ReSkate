import SwiftUI

struct SettingsView: View {
    @Environment(CrossOverService.self) private var crossOver

    var body: some View {
        Form {
            Section("CrossOver Preview") {
                if let install = crossOver.install {
                    LabeledContent("Bundle") {
                        Text(install.bundleURL.path)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                } else {
                    Text("CrossOver Preview not installed")
                        .foregroundStyle(.orange)
                }
            }
            Section("Bottle") {
                LabeledContent("Name", value: CrossOverService.preferredName)
                if let bottle = crossOver.bottle {
                    LabeledContent("Path") {
                        Text(bottle.url.path)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                } else {
                    Text("`skate-fex` not present")
                        .foregroundStyle(.orange)
                }
            }
            Section {
                Button("Re-scan") {
                    crossOver.rescan()
                }
            }
        }
        .padding()
        .frame(width: 520)
    }
}
