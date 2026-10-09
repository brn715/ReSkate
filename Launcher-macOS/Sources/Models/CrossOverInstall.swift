import Foundation

/// One install of CrossOver (or Preview) on this Mac: its `/Applications` bundle,
/// the helper `wine` CLI binary it ships, and the folder where its bottles live.
public struct CrossOverInstall: Identifiable, Hashable, Sendable {
    public var id: String { bundleURL.path }

    public let flavor: Bottle.Flavor
    public let bundleURL: URL

    public var wineCLI: URL {
        bundleURL
            .appendingPathComponent("Contents/SharedSupport/CrossOver/bin/wine")
    }

    public var bottlesRoot: URL {
        // CrossOver (stable and Preview) resolves bottles via this path. The
        // user may have it symlinked to a custom location; we preserve the
        // symlink rather than resolve it, so all writes go wherever the user
        // originally pointed CrossOver.
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "Library/Application Support/CrossOver/Bottles",
                isDirectory: true
            )
    }

    public static func detect() -> [CrossOverInstall] {
        let fm = FileManager.default
        return [
            (Bottle.Flavor.stable, URL(fileURLWithPath: "/Applications/CrossOver.app")),
            (Bottle.Flavor.preview, URL(fileURLWithPath: "/Applications/CrossOver Preview.app")),
        ]
        .filter { (_, url) in
            fm.fileExists(
                atPath: url.appendingPathComponent("Contents/MacOS").path
            )
        }
        .map { CrossOverInstall(flavor: $0, bundleURL: $1) }
    }
}
