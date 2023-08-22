import Foundation

extension Bundle {
    private enum Constants {
        static let versionKey = "CFBundleShortVersionString"
        static let buildNumberKey = "CFBundleVersion"
        static let displayNameKey = "CFBundleDisplayName"
    }

    var bundleVersion: String {
        guard let bundleVersion = object(forInfoDictionaryKey: Constants.versionKey) as? String else {
            fatalError("Version not available in Info.plist for bundle: \(self)")
        }
        return bundleVersion
    }

    var buildNumber: String {
        guard let buildNumber = object(forInfoDictionaryKey: Constants.buildNumberKey) as? String else {
            fatalError("Build number not available in Info.plist for bundle: \(self)")
        }
        return buildNumber
    }

    var displayName: String {
        guard let displayName = object(forInfoDictionaryKey: Constants.displayNameKey) as? String else {
            fatalError("Display name not available in Info.plist for bundle: \(self)")
        }
        return displayName
    }
}
