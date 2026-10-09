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

    public var driveC: URL {
        url.appendingPathComponent("drive_c", isDirectory: true)
    }

    public var reSkateDir: URL {
        driveC.appendingPathComponent("ReSkate", isDirectory: true)
    }

    public var reSkateLogURL: URL {
        reSkateDir.appendingPathComponent("logs/ReSkate.log")
    }

    public var hasGameInstalled: Bool {
        FileManager.default.fileExists(
            atPath: reSkateDir.appendingPathComponent("Skate.exe").path
        )
    }

    public var hasLauncherInstalled: Bool {
        FileManager.default.fileExists(
            atPath: reSkateDir.appendingPathComponent("ReSkateLauncher.exe").path
        )
    }

    public var modsDir: URL {
        reSkateDir.appendingPathComponent("Mods", isDirectory: true)
    }
}
