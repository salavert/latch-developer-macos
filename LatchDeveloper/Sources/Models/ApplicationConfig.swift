import Foundation

public struct ApplicationConfig: Equatable {
    public let appId: String
    public let appSecret: String
    public let host: String?
    public let userId: String?
    public let userSecret: String?
    
    init(
        appId: String,
        appSecret: String,
        host: String? = ApplicationConstants.defaultHost,
        userId: String?,
        userSecret: String?
    ) {
        self.appId = appId
        self.appSecret = appSecret
        self.userId = userId
        self.userSecret = userSecret
        self.host = host
    }
    
    var isValid: Bool {
        guard let host, !host.isEmpty, URL(string: host) != nil else {
            return false
        }
        if !appId.isEmpty && !appSecret.isEmpty {
            return true
        }
        if let userId, !userId.isEmpty, let userSecret, !userSecret.isEmpty {
            return true
        }
        return false
    }
}

extension ApplicationConfig: CustomStringConvertible {
    public var description: String {
        """
        [ApplicationConfig]
            AppId: \(appId)
            AppSecret: \(appSecret)
            Host: \(host ?? "")
            UserId: \(String(describing: userId))
            UserSecret: \(String(describing: userSecret))
        """
    }
    
    
}
