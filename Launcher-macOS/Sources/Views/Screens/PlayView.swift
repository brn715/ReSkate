import SwiftUI

struct PlayView: View {
    @Environment(CrossOverService.self) private var crossOver
    @State private var isLaunching = false
    @State private var launchError: String?
    @State private var lastLaunchPID: pid_t?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.system(size: 88))
                .foregroundStyle(.tint)

            if let bottle = crossOver.bottle {
                VStack(spacing: 8) {
                    Text("Launching in: \(bottle.name)")
                        .font(.headline)
                    Text(bottle.url.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            } else {
                Text("`skate-fex` bottle not found in CrossOver Preview")
                    .foregroundStyle(.orange)
            }

            Button(action: launchGame) {
                Label("Play", systemImage: "play.fill")
                    .font(.title2)
                    .frame(minWidth: 240)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(crossOver.bottle == nil || isLaunching)

            if let err = launchError {
                Text(err).foregroundStyle(.red).font(.caption)
            }
            if let pid = lastLaunchPID {
                Text("Launched, wine pid \(pid)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func launchGame() {
        guard let bottle = crossOver.bottle,
              let install = crossOver.install else {
            launchError = "CrossOver Preview install missing."
            return
        }
        launchError = nil
        isLaunching = true

        Task {
            let windowsPath = "C:\\ReSkate\\ReSkateLauncher.exe"
            let args: [String] = ["--no-gui"]
            do {
                let proc = WineProcess(install: install, bottle: bottle)
                let pid = try await proc.launch(.cxApp(windowsPath: windowsPath, args: args))
                await MainActor.run {
                    lastLaunchPID = pid
                    isLaunching = false
                }
            } catch {
                await MainActor.run {
                    launchError = error.localizedDescription
                    isLaunching = false
                }
            }
        }
    }
}
