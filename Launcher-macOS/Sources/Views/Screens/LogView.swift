import SwiftUI

struct LogView: View {
    @Environment(CrossOverService.self) private var crossOver
    @State private var lines: [String] = []
    @State private var autoScroll = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ReSkate.log").font(.headline)
                Spacer()
                Toggle("Auto-scroll", isOn: $autoScroll)
                    .toggleStyle(.switch)
                Button("Clear") { lines.removeAll() }
            }
            .padding()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .id(idx)
                                .padding(.vertical, 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(nsColor: .textBackgroundColor))
                .onChange(of: lines.count) { _, newCount in
                    guard autoScroll, newCount > 0 else { return }
                    proxy.scrollTo(newCount - 1, anchor: .bottom)
                }
            }
        }
        .task(id: crossOver.bottle?.id) {
            guard let url = crossOver.bottle?.reSkateLogURL else { return }
            let tailer = LogTailer(url: url)
            for await line in tailer.lines() {
                lines.append(line)
                if lines.count > 2000 { lines.removeFirst(lines.count - 2000) }
            }
        }
    }
}
