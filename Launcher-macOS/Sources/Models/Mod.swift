import Foundation

public struct Mod: Identifiable, Hashable, Codable, Sendable {
    public let id: String                 // thunderstore package uuid4
    public let name: String
    public let namespace: String          // e.g. "FAKIE"
    public let version: String
    public let description: String
    public let downloads: Int
    public let rating: Int
    public let downloadURL: URL
    public let categories: [String]

    public var slug: String { "\(namespace)-\(name)" }
}

public struct InstalledMod: Identifiable, Hashable, Sendable {
    public var id: String { folder.lastPathComponent }
    public let folder: URL
    public let slug: String

    public static func scan(in bottle: Bottle) -> [InstalledMod] {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(
            at: bottle.modsDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return entries
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }
            .map { InstalledMod(folder: $0, slug: $0.lastPathComponent) }
    }
}
