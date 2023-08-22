import Dependencies
import Foundation

public typealias Operations = [String: String]
public typealias Accounts = [String]

public struct RepositoryClient {
    public var getAccounts: () -> Accounts
    public var setAccounts: (Accounts) -> Void

    public var getOperations: () -> Operations
    public var setOperations: (Operations) -> Void

    public var getApplicationConfig: () -> ApplicationConfig?
    public var setApplicationConfig: (ApplicationConfig) -> Void
    
    public var getCurrentApplicationId: () -> String?
    public var setCurrentApplicationId: (String?) -> Void

    public var clearCurrentApplicationRelatedData: () -> Void
    public var clearAll: () -> Void
}

extension RepositoryClient: DependencyKey {
    public static let liveValue = Self(
        getAccounts: { accounts },
        setAccounts: { Self.accounts = $0 },
        getOperations: { operations }, 
        setOperations: { Self.operations = $0 },
        getApplicationConfig: { applicationConfig },
        setApplicationConfig: { Self.applicationConfig = $0 },
        getCurrentApplicationId: { applicationId },
        setCurrentApplicationId: { Self.applicationId = $0 },
        clearCurrentApplicationRelatedData: {
            accounts = []
            operations = [:]
        },
        clearAll: {
            clearAllUserDefaults()
        }
    )
}

private extension RepositoryClient {
    static func clearAllUserDefaults() -> Void {
        @Dependency(\.userDefaultsClient) var userDefaultsClient
        userDefaultsClient.clearAll()
    }
    
    static var applicationId: String? {
        get {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            return userDefaultsClient.value(forKey: .appId)
        }
        set {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            userDefaultsClient.set(newValue, forKey: .appId)
        }
    }
    
    static var accounts: Accounts {
        get {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            return userDefaultsClient.value(forKey: .pairedAccounts) ?? []
        }
        set {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            userDefaultsClient.set(newValue, forKey: .pairedAccounts)
        }
    }
    
    static var operations: Operations {
        get {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            return userDefaultsClient.value(forKey: .operations) as? Operations ?? [:]
        }
        set {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            userDefaultsClient.set(newValue, forKey: .operations)
        }
    }
    
    static var applicationConfig: ApplicationConfig? {
        get {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            return .init(
                appId: userDefaultsClient.value(forKey: .appId) ?? "",
                appSecret: userDefaultsClient.value(forKey: .appSecret) ?? "",
                host: userDefaultsClient.value(forKey: .host) ?? ApplicationConstants.defaultHost,
                userId: userDefaultsClient.value(forKey: .userId),
                userSecret: userDefaultsClient.value(forKey: .userSecret)
            )
        }
        set {
            @Dependency(\.userDefaultsClient) var userDefaultsClient
            guard let newValue else { return }
            userDefaultsClient.set(!newValue.appId.isEmpty ? newValue.appId : nil, forKey: .appId)
            userDefaultsClient.set(!newValue.appSecret.isEmpty ? newValue.appSecret : nil, forKey: .appSecret)
            userDefaultsClient.set(newValue.host, forKey: .host)
            if let userId = newValue.userId, !userId.isEmpty {
                userDefaultsClient.set(userId, forKey: .userId)
            } else {
                userDefaultsClient.set(nil, forKey: .userId)
            }
            if let userSecret = newValue.userSecret, !userSecret.isEmpty {
                userDefaultsClient.set(userSecret, forKey: .userSecret)
            } else {
                userDefaultsClient.set(nil, forKey: .userSecret)
            }
        }
    }
}

extension DependencyValues {
    public var repositoryClient: RepositoryClient {
        get { self[RepositoryClient.self] }
        set { self[RepositoryClient.self] = newValue }
    }
}
