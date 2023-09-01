import Foundation

enum ApplicationConstants {
    static var appCenterSecret: String {
        "a0cc41e8-af70-4f5d-9a11-5e96a335bb1e"
    }

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
