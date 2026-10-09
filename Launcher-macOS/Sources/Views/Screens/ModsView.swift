import SwiftUI

struct ModsView: View {
    @Environment(CrossOverService.self) private var crossOver
    @State private var searchText = ""
    @State private var remote: [Mod] = []
    @State private var installed: [InstalledMod] = []
    @State private var isLoading = false
    @State private var lastError: String?

    private let ts = ThunderstoreService()

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if let bottle = crossOver.bottle {
                HStack {
                    Text("Installing into \(bottle.modsDir.path)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else {
                Label("`skate-fex` bottle not found", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .padding(.horizontal)
            }

            List(selection: .constant(Optional<Mod>.none)) {
                Section("Installed (\(installed.count))") {
                    ForEach(installed) { mod in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(mod.slug).font(.headline)
                                Text(mod.folder.path)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                try? ts.remove(mod)
                                rescan()
                            } label: { Image(systemName: "trash") }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section("Thunderstore (\(filtered.count))") {
                    ForEach(filtered) { mod in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(mod.namespace)-\(mod.name)")
                                    .font(.headline)
                                Text(mod.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                HStack(spacing: 12) {
                                    Label("\(mod.downloads)", systemImage: "arrow.down.circle")
                                    Label("\(mod.rating)", systemImage: "star.fill")
                                    Text(mod.version)
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                Task { await install(mod) }
                            } label: {
                                Image(systemName: "arrow.down.to.line")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(installed.contains(where: { $0.slug == mod.slug }))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $searchText, placement: .sidebar)
        }
        .task { await reload() }
    }

    private var headerBar: some View {
        HStack {
            Text("Mods").font(.largeTitle.bold())
            Spacer()
            if isLoading { ProgressView().controlSize(.small) }
            Button { Task { await reload() } } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .padding()
    }

    private var filtered: [Mod] {
        guard !searchText.isEmpty else { return remote }
        let q = searchText.lowercased()
        return remote.filter {
            $0.name.lowercased().contains(q)
            || $0.namespace.lowercased().contains(q)
            || $0.description.lowercased().contains(q)
        }
    }

    private func reload() async {
        isLoading = true
        defer { isLoading = false }
        do {
            remote = try await ts.allPackages().sorted { $0.downloads > $1.downloads }
            rescan()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func install(_ mod: Mod) async {
        guard let bottle = crossOver.bottle else { return }
        do {
            _ = try await ts.install(mod, into: bottle)
            rescan()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func rescan() {
        if let bottle = crossOver.bottle {
            installed = InstalledMod.scan(in: bottle)
        }
    }
}
