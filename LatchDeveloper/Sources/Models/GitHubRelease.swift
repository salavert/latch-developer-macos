import Foundation

struct GitHubRelease: Codable {
    let name: String
    let draft: Bool
    let prerelease: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case draft
        case prerelease
    }
}
