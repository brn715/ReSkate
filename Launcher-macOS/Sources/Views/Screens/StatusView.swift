import SwiftUI

struct StatusView: View {
    @Environment(CrossOverService.self) private var crossOver
    @State private var latest: GitHubService.Release?
    @State private var lastError: String?

    private let github = GitHubService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                GroupBox("CrossOver Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        if let install = crossOver.install {
                            LabeledContent("Install") {
                                Text(install.bundleURL.path)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }
                        } else {
                            Label("CrossOver Preview not found in /Applications", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }

                        if let bottle = crossOver.bottle {
                            LabeledContent("Bottle", value: bottle.name)
                            LabeledContent("Launcher installed") {
                                Image(systemName: bottle.hasLauncherInstalled ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(bottle.hasLauncherInstalled ? .green : .orange)
                            }
                            LabeledContent("Skate installed") {
                                Image(systemName: bottle.hasGameInstalled ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(bottle.hasGameInstalled ? .green : .orange)
                            }
                        } else {
                            Label("Bottle `skate-fex` missing in CrossOver Preview", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("Latest ReSkate release") {
                    VStack(alignment: .leading, spacing: 6) {
                        if let latest {
                            LabeledContent("Tag", value: latest.tagName)
                            if let pub = latest.publishedAt {
                                LabeledContent("Published", value: pub.formatted(date: .abbreviated, time: .shortened))
                            }
                            LabeledContent("Assets", value: "\(latest.assets.count)")
                            Link("Open on GitHub", destination: latest.htmlURL)
                        } else if let lastError {
                            Text(lastError).foregroundStyle(.red)
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            do {
                latest = try await github.latestRelease()
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ReSkate for macOS")
                .font(.largeTitle.bold())
            Text("Native launcher driving the `skate-fex` Preview bottle.")
                .foregroundStyle(.secondary)
        }
    }
}
