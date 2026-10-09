import Foundation

public struct Bottle: Identifiable, Hashable, Codable, Sendable {
    public enum Flavor: String, Codable, Sendable, CaseIterable {
        case stable = "CrossOver"
        case preview = "CrossOver Preview"
    }

    public var id: String { url.path }

    public let name: String
    public let flavor: Flavor
    public let url: URL

    /// `drive_c` directory inside this bottle.
    public var driveC: URL {
        url.appendingPathComponent("drive_c", isDirectory: true)
    }

    /// Standard install location this launcher writes ReSkate into.
    public var reSkateDir: URL {
        driveC.appendingPathComponent("ReSkate", isDirectory: true)
    }

    /// Path the Windows-side launcher writes its log to.
    public var reSkateLogURL: URL {
        reSkateDir.appendingPathComponent("logs/ReSkate.log")
    }

    /// True if `Skate.exe` lands beside the launcher — meaning depot install finished.
    public var hasGameInstalled: Bool {
        FileManager.default.fileExists(
            atPath: reSkateDir.appendingPathComponent("Skate.exe").path
        )
    }

    /// True if the launcher executable itself is present.
    public var hasLauncherInstalled: Bool {
        FileManager.default.fileExists(
            atPath: reSkateDir.appendingPathComponent("ReSkateLauncher.exe").path
        )
    }

    /// Mods directory the launcher merges at boot.
    public var modsDir: URL {
        reSkateDir.appendingPathComponent("Mods", isDirectory: true)
    }
}
