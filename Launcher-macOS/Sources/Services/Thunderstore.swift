import Foundation

/// Client for Thunderstore's community API, scoped to the `reskate` namespace.
public actor ThunderstoreService {
    private struct Package: Decodable {
        let name: String
        let fullName: String
        let owner: String
        let packageUrl: URL
        let dateCreated: Date?
        let dateUpdated: Date?
        let ratingScore: Int
        let isPinned: Bool
        let isDeprecated: Bool
        let hasNsfwContent: Bool
        let categories: [String]
        let uuid4: String
        let versions: [Version]

        enum CodingKeys: String, CodingKey {
            case name
            case fullName = "full_name"
            case owner
            case packageUrl = "package_url"
            case dateCreated = "date_created"
            case dateUpdated = "date_updated"
            case ratingScore = "rating_score"
            case isPinned = "is_pinned"
            case isDeprecated = "is_deprecated"
            case hasNsfwContent = "has_nsfw_content"
            case categories
            case uuid4
            case versions
        }
    }

    private struct Version: Decodable {
        let name: String
        let fullName: String
        let description: String
        let icon: URL?
        let versionNumber: String
        let dependencies: [String]
        let downloadUrl: URL
        let downloads: Int
        let dateCreated: Date?
        let websiteUrl: URL?
        let isActive: Bool
        let uuid4: String
        let fileSize: Int

        enum CodingKeys: String, CodingKey {
            case name
            case fullName = "full_name"
            case description
            case icon
            case versionNumber = "version_number"
            case dependencies
            case downloadUrl = "download_url"
            case downloads
            case dateCreated = "date_created"
            case websiteUrl = "website_url"
            case isActive = "is_active"
            case uuid4
            case fileSize = "file_size"
        }
    }

    public init() {}

    /// Fetch every package in `reskate`, mapped to the slim `Mod` shape.
    public func allPackages() async throws -> [Mod] {
        let url = URL(string: "https://thunderstore.io/api/experimental/community/reskate/package/")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(
                domain: "Thunderstore",
                code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                userInfo: [NSLocalizedDescriptionKey: "Thunderstore API non-200"]
            )
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let packages = try decoder.decode([Package].self, from: data)
        return packages.compactMap { pkg -> Mod? in
            // Latest active version is what the launcher would install.
            guard let latest = pkg.versions.first(where: { $0.isActive })
                    else { return nil }
            return Mod(
                id: pkg.uuid4,
                name: pkg.name,
                namespace: pkg.owner,
                version: latest.versionNumber,
                description: latest.description,
                downloads: pkg.versions.reduce(0) { $0 + $1.downloads },
                rating: pkg.ratingScore,
                downloadURL: latest.downloadUrl,
                categories: pkg.categories
            )
        }
    }

    /// Download a mod zip and extract into the bottle's `Mods/` folder.
    public func install(_ mod: Mod, into bottle: Bottle) async throws -> URL {
        let modsDir = bottle.modsDir
        try FileManager.default.createDirectory(at: modsDir, withIntermediateDirectories: true)

        // Fetch zip into a temp dir
        let (tmpZip, _) = try await URLSession.shared.download(from: mod.downloadURL)

        // Thunderstore zips for ReSkate contain the mod contents at their root
        // (initfs_win32/…) or under a single folder. We expand into a known
        // staging area, then move into Mods/<namespace>-<name>/.
        let staging = FileManager.default.temporaryDirectory
            .appendingPathComponent("reskate-mod-\(mod.slug)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: staging) }

        let unzip = Process()
        unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzip.arguments = ["-q", tmpZip.path, "-d", staging.path]
        try unzip.run()
        unzip.waitUntilExit()
        guard unzip.terminationStatus == 0 else {
            throw NSError(domain: "ModInstall", code: Int(unzip.terminationStatus))
        }

        // Determine whether the zip had a top-level folder for the mod.
        let fm = FileManager.default
        let stagingEntries = try fm.contentsOfDirectory(at: staging, includingPropertiesForKeys: nil)
        let sourceRoot: URL
        if stagingEntries.count == 1,
           (try? stagingEntries[0].resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
            sourceRoot = stagingEntries[0]
        } else {
            sourceRoot = staging
        }

        let destination = modsDir.appendingPathComponent(mod.slug, isDirectory: true)
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: sourceRoot, to: destination)
        return destination
    }

    public nonisolated func remove(_ mod: InstalledMod) throws {
        try FileManager.default.removeItem(at: mod.folder)
    }
}
