import Foundation

/// Async wrapper around CrossOver's bundled `wine` CLI.
public actor WineProcess {
    public enum Action: Sendable {
        /// Run a Windows executable by its `C:\...` path inside the bottle.
        case cxApp(windowsPath: String, args: [String])
    }

    public let install: CrossOverInstall
    public let bottle: Bottle

    public init(install: CrossOverInstall, bottle: Bottle) {
        self.install = install
        self.bottle = bottle
    }

    /// Spawn wine without waiting for it. Returns the PID.
    @discardableResult
    public func launch(_ action: Action) throws -> pid_t {
        let process = Process()
        process.executableURL = install.wineCLI

        var argv: [String] = ["--bottle", bottle.name]
        switch action {
        case .cxApp(let path, let args):
            argv.append(contentsOf: ["--cx-app", path])
            argv.append(contentsOf: args)
        }
        process.arguments = argv
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try process.run()
        return process.processIdentifier
    }

    /// Spawn and tail stdout. Returns an async stream of lines.
    public func stream(_ action: Action) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let process = Process()
            process.executableURL = install.wineCLI

            var argv: [String] = ["--bottle", bottle.name]
            switch action {
            case .cxApp(let path, let args):
                argv.append(contentsOf: ["--cx-app", path])
                argv.append(contentsOf: args)
            }
            process.arguments = argv

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            let handle = pipe.fileHandleForReading
            handle.readabilityHandler = { fh in
                let data = fh.availableData
                if data.isEmpty { return }
                if let s = String(data: data, encoding: .utf8) {
                    for line in s.split(whereSeparator: \.isNewline) {
                        continuation.yield(String(line))
                    }
                }
            }
            process.terminationHandler = { p in
                if p.terminationStatus != 0 {
                    continuation.finish(
                        throwing: NSError(
                            domain: "WineProcess",
                            code: Int(p.terminationStatus),
                            userInfo: [NSLocalizedDescriptionKey: "wine exited \(p.terminationStatus)"]
                        )
                    )
                } else {
                    continuation.finish()
                }
            }

            do {
                try process.run()
            } catch {
                continuation.finish(throwing: error)
            }

            continuation.onTermination = { _ in
                if process.isRunning { process.terminate() }
            }
        }
    }

    /// Path translation: bottle-local `drive_c/Sub/Path` → `C:\Sub\Path`.
    public static func toWindowsPath(_ driveCPath: String) -> String {
        let stripped = driveCPath.hasPrefix("/") ? String(driveCPath.dropFirst()) : driveCPath
        return "C:\\" + stripped
            .replacingOccurrences(of: "drive_c/", with: "")
            .replacingOccurrences(of: "/", with: "\\")
    }
}
