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

                GroupBox("Environment") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("CrossOver installs") {
                            Text(crossOver.installs.map(\.flavor.rawValue).joined(separator: ", "))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Bottles") { Text("\(crossOver.bottles.count)") }
                        LabeledContent("Active bottle") {
                            Text(crossOver.primaryBottle()?.name ?? "—")
                                .foregroundStyle(.secondary)
                        }
                        if let bottle = crossOver.primaryBottle() {
                            LabeledContent("Skate installed") {
                                Image(systemName: bottle.hasGameInstalled ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(bottle.hasGameInstalled ? .green : .orange)
                            }
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

                if let lastError {
                    Text(lastError)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            Text("Native launcher driving the Windows ReSkate runtime inside CrossOver.")
                .foregroundStyle(.secondary)
        }
    }
}
