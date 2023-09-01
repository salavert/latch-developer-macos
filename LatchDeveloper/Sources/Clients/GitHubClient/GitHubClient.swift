import Dependencies
import Foundation

public struct GitHubClient {
    public var getLatestReleaseTag: @Sendable () async throws -> String?
}

extension GitHubClient: DependencyKey {
    public static let liveValue = Self(
        getLatestReleaseTag: {
            try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: ApplicationConstants.githubLatestReleaseURL) { (data, response, error) in
                    if let githubRelease = data?.decodeAs(GitHubRelease.self),
                       !githubRelease.draft,
                       !githubRelease.prerelease {
                        continuation.resume(returning: githubRelease.name)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }.resume()
            }
        }
    )
}

extension DependencyValues {
    public var gitHubClient: GitHubClient {
        get { self[GitHubClient.self] }
        set { self[GitHubClient.self] = newValue }
    }
}
