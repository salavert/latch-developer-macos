import Dependencies
import Foundation

// MARK: UserDefaultsClient Keys

public extension UserDefaultsClient.Key {
    static var appId: UserDefaultsClient.Key<String> { .init("appId", domain: .app) }
    static var appSecret: UserDefaultsClient.Key<String> { .init("appSecret", domain: .app) }
    static var host: UserDefaultsClient.Key<String> { .init("host", domain: .app) }
    static var userId: UserDefaultsClient.Key<String> { .init("userId", domain: .app) }
    static var userSecret: UserDefaultsClient.Key<String> { .init("userSecret", domain: .app) }
    static var pairedAccounts: UserDefaultsClient.Key<[String]> { .init("pairedAccounts", domain: .app) }
    static var operations: UserDefaultsClient.Key<[String: Any]> { .init("operations", domain: .app) }
}

public extension UserDefaultsClient {
    static func live(
        userDefaults: UserDefaults = .standard
    ) -> UserDefaultsClient {
        .init(
            boolForKey: { userDefaults.value(forKey: $0.value) as? Bool },
            stringForKey: { userDefaults.string(forKey: $0.value) },
            stringArrayForKey: { userDefaults.stringArray(forKey: $0.value) },
            dataForKey: { userDefaults.data(forKey: $0.value) },
            dictionaryForKey: { userDefaults.dictionary(forKey: $0.value) },
            doubleForKey: { userDefaults.value(forKey: $0.value) as? Double },
            integerForKey: { userDefaults.value(forKey: $0.value) as? Int },
            setBool: { userDefaults.setValue($1, forKey: $0.value) },
            setString: { userDefaults.set($1, forKey: $0.value) },
            setStringArray: { userDefaults.set($1, forKey: $0.value) },
            setData: { userDefaults.set($1, forKey: $0.value) },
            setDictionary: { userDefaults.set($1, forKey: $0.value) },
            setDouble: { userDefaults.set($1, forKey: $0.value) },
            setInteger: { userDefaults.set($1, forKey: $0.value) },
            clear: { domain in
                userDefaults
                    .dictionaryRepresentation()
                    .keys
                    // Only remove those values which keys were stored using
                    // `UserDefaultsClient` key structure: com.tef.user.any-random-key
                    .filter { $0.starts(with: "\(domain.value).") }
                    .forEach(userDefaults.removeObject)
                userDefaults.synchronize()
            }
        )
    }
}

// MARK: DependencyKey

extension UserDefaultsClient: DependencyKey {
    public static let liveValue: UserDefaultsClient = .live()
}

// MARK: DependencyValues

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
