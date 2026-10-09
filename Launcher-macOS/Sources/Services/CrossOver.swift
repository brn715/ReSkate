import Foundation

/// Hardcoded single-bottle mode: we only care about the FEX Preview bottle
/// named `skate-fex`. Swap `preferredName` / `preferredFlavor` if that changes.
@Observable
public final class CrossOverService {
    public static let preferredName = "skate-fex"
    public static let preferredFlavor = Bottle.Flavor.preview

    public private(set) var install: CrossOverInstall?   // Preview install only
    public private(set) var bottle: Bottle?              // skate-fex only

    public init() {
        rescan()
    }

    public func rescan() {
        let all = CrossOverInstall.detect()
        install = all.first(where: { $0.flavor == Self.preferredFlavor })

        guard let install else {
            bottle = nil
            return
        }

        let candidate = install.bottlesRoot.appendingPathComponent(Self.preferredName, isDirectory: true)
        let fm = FileManager.default
        let driveC = candidate.appendingPathComponent("drive_c", isDirectory: true)
        bottle = fm.fileExists(atPath: driveC.path)
            ? Bottle(name: Self.preferredName, flavor: install.flavor, url: candidate)
            : nil
    }

    /// Compatibility shim for views that used to iterate many bottles.
    public func primaryBottle() -> Bottle? { bottle }
}
