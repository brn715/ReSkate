import Foundation

/// Bottle inventory across all installed CrossOver flavors.
@Observable
public final class CrossOverService {
    public private(set) var installs: [CrossOverInstall] = []
    public private(set) var bottles: [Bottle] = []

    public init() {
        rescan()
    }

    public func rescan() {
        installs = CrossOverInstall.detect()
        var found: [Bottle] = []
        for install in installs {
            let bottlesRoot = install.bottlesRoot
            let fm = FileManager.default
            guard let entries = try? fm.contentsOfDirectory(
                at: bottlesRoot,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }
            for entry in entries where (try? entry.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                // Skip noise: real bottles have a drive_c inside.
                let driveC = entry.appendingPathComponent("drive_c", isDirectory: true)
                guard fm.fileExists(atPath: driveC.path) else { continue }
                found.append(Bottle(name: entry.lastPathComponent, flavor: install.flavor, url: entry))
            }
        }
        bottles = found.sorted { $0.name < $1.name }
    }

    /// The single bottle that currently holds a ReSkate install, if any.
    public func primaryBottle() -> Bottle? {
        bottles.first(where: { $0.hasLauncherInstalled })
    }
}
