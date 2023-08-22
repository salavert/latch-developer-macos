import Dependencies
import LatchSDK
import LatchSharedModels
import Foundation

public struct NetworkClient {
    public var addOperation: @Sendable (String, String, OptionalFeature, OptionalFeature) async throws -> LatchResponse
    public var applications: @Sendable () async throws -> LatchResponse
    public var deleteOperation: @Sendable (String) async throws -> LatchResponse
    public var history: @Sendable (String) async throws -> LatchResponse
    public var lock: @Sendable (String, String) async throws -> LatchResponse
    public var operationStatus: @Sendable (String, String, Bool, Bool) async throws -> LatchResponse
    public var pair: @Sendable (String) async throws -> LatchResponse
    public var subscription: @Sendable () async throws -> LatchResponse
    public var unlock: @Sendable (String, String) async throws -> LatchResponse
    public var unpair: @Sendable (String) async throws -> LatchResponse
}

extension NetworkClient: DependencyKey {
    public static let liveValue: Self = {
        var latchSDK: LatchSDK {
            @Dependency(\.repositoryClient) var repositoryClient
            let applicationConfig = repositoryClient.getApplicationConfig()
            
            var baseUrl: URL
            if let host = applicationConfig?.host, !host.isEmpty {
                baseUrl = URL(string: host)!
            } else {
                baseUrl = URL(string: ApplicationConstants.defaultHost)!
            }
            
            return LatchSDK(
                appId: applicationConfig?.appId ?? "",
                appSecret: applicationConfig?.appSecret ?? "",
                apiUserId: applicationConfig?.userId ?? "",
                apiUserSecret: applicationConfig?.userSecret ?? "",
                baseUrl: baseUrl
            )
        }
        
        return Self(
            addOperation: { parentId, name, twoFactor, lockOnRequest in
                try await latchSDK.addOperation(
                    parentId: parentId,
                    details: .init(
                        name: name,
                        twoFactor: twoFactor,
                        lockOnRequest: lockOnRequest
                    )
                )
            }, 
            applications: {
                try await latchSDK.getUserApplications()
            },
            deleteOperation: { operationId in
                try await latchSDK.deleteOperation(operationId: operationId)
            },
            history: { accountId in
                try await latchSDK.history(accountId: accountId)
            },
            lock: { accountId, operationId in
                try await latchSDK.lock(
                    accountId: accountId,
                    operationId: operationId
                )
            },
            operationStatus: { accountId, operationId, silent, noOTP in
                try await latchSDK.operationStatus(
                    accountId: accountId,
                    operationId: operationId,
                    silent: silent,
                    noOTP: noOTP
                )
            },
            pair: { token in
                try await latchSDK.pair(token: token)
            },
            subscription: {
                try await latchSDK.subscription()
            },
            unlock: { accountId, operationId in
                try await latchSDK.unlock(
                    accountId: accountId,
                    operationId: operationId
                )
            },
            unpair: { accountId in
                try await latchSDK.unpair(accountId: accountId)
            }
        )
    }()
}

extension DependencyValues {
    public var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}
