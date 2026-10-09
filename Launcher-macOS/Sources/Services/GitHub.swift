import Foundation

/// Minimal async GitHub Releases client for the upstream repo.
public actor GitHubService {
    public struct Release: Codable, Sendable, Identifiable {
        public var id: String { tagName }
        public let tagName: String
        public let name: String
        public let publishedAt: Date?
        public let assets: [Asset]
        public let htmlURL: URL

        public struct Asset: Codable, Sendable {
            public let name: String
            public let size: Int
            public let browserDownloadURL: URL
        }

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case name
            case publishedAt = "published_at"
            case assets
            case htmlURL = "html_url"
        }
    }

    public init() {}

    public func latestRelease(
        owner: String = "Dingo-Shenanigans",
        repo: String = "ReSkate"
    ) async throws -> Release {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("reskate-mac-launcher", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(
                domain: "GitHub",
                code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                userInfo: [NSLocalizedDescriptionKey: "GitHub returned non-200"]
            )
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Release.self, from: data)
    }
}
