import Foundation

enum ApplicationConstants {
    static var appVersion: String {
        Bundle.main.bundleVersion
    }

    static var buildNumber: String {
        Bundle.main.buildNumber
    }

    static var defaultHost: String {
        "https://latch.telefonica.com"
    }
    
    static var defaultMenuOption: MenuOption {
        MenuOption.applications.disabled ? .pair : .applications
    }
    
    static var appCenterPublicGroupURL: URL {
        URL(string: "https://install.appcenter.ms/orgs/tuenti-organization/apps/latch-developer-for-macos/distribution_groups/public")!
    }
    
    static var githubLatestReleaseURL: URL {
        URL(string: "https://api.github.com/repos/salavert/latch-developer-macos/releases/latest")!
    }
}
