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
}
