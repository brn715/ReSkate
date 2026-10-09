import Foundation

/// Async stream of lines appended to a file. Polls on a fixed cadence (no
/// kqueue/DispatchSource — fine for a log file the launcher rewrites freely).
public struct LogTailer: Sendable {
    public let url: URL
    public let pollInterval: Duration

    public init(url: URL, pollInterval: Duration = .milliseconds(500)) {
        self.url = url
        self.pollInterval = pollInterval
    }

    public func lines(fromOffset offset: UInt64 = 0) -> AsyncStream<String> {
        AsyncStream { continuation in
            let task = Task {
                var position = offset
                while !Task.isCancelled {
                    do {
                        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                        let fileSize = (attrs[.size] as? NSNumber)?.uint64Value ?? 0

                        if fileSize < position {
                            // Truncated / rotated — restart from 0.
                            position = 0
                        }
                        if fileSize > position {
                            let handle = try FileHandle(forReadingFrom: url)
                            try handle.seek(toOffset: position)
                            let data = handle.readDataToEndOfFile()
                            try handle.close()
                            position = UInt64(data.count) + position
                            if let text = String(data: data, encoding: .utf8) {
                                for line in text.split(whereSeparator: \.isNewline) {
                                    continuation.yield(String(line))
                                }
                            }
                        }
                    } catch {
                        // File may not exist yet. Keep polling.
                    }
                    try? await Task.sleep(for: pollInterval)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
