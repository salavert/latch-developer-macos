import Dependencies
import Foundation

public enum MenuOption: String, CaseIterable, Identifiable {
    case applications
    case pair
    case unpair
    case status
    case operations
    case manageInstances
    case userHistory
    case subscription
    case logs
    
    public var id: String { rawValue }
}

private extension MenuOption {
    static var hasApplicationKeys: Bool {
        @Dependency(\.repositoryClient) var repositoryClient
        let applicationConfig = repositoryClient.getApplicationConfig()
        let appId = applicationConfig?.appId ?? ""
        let appSecret = applicationConfig?.appSecret ?? ""
        return !appId.isEmpty && !appSecret.isEmpty
    }
    
    static var hasUserApiKeys: Bool {
        @Dependency(\.repositoryClient) var repositoryClient
        let applicationConfig = repositoryClient.getApplicationConfig()
        let userId = applicationConfig?.userId ?? ""
        let userSecret = applicationConfig?.userSecret ?? ""
        return !userId.isEmpty && !userSecret.isEmpty
    }
}

extension MenuOption {
    public var title: String {
        switch self {
        case .pair:
            "Pair account"
        case .unpair:
            "Unpair  account"
        case .status:
            "Account status"
        case .operations:
            "Operations"
        case .manageInstances:
            "Instances"
        case .userHistory:
            "User history"
        case .applications:
            "Applications"
        case .subscription:
            "Subscription"
        case .logs:
            "Logs"
        }
    }
    
    public var icon: String {
        switch self {
        case .pair:
            "person.2"
        case .unpair:
            "person.2.slash"
        case .status:
            "person.circle"
        case .operations:
            "square.stack.3d.up"
        case .manageInstances:
            "hockey.puck"
        case .userHistory:
            "clock"
        case .applications:
            "rectangle.stack"
        case .subscription:
            "dollarsign"
        case .logs:
            "text.line.first.and.arrowtriangle.forward"
        }
    }
    
    var disabled: Bool {
        switch self {
        case .pair,
                .logs,
                .unpair,
                .status,
                .operations,
                .userHistory:
            return !Self.hasApplicationKeys
        case .manageInstances:
            return true
        case .applications,
                .subscription:
            return !Self.hasUserApiKeys
        }
    }
}

public enum OperationSubMenu: String, Equatable, Sendable, CaseIterable, Identifiable  {
    case addOperation
    case deleteOperation
    
    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .addOperation:
            "square.stack.3d.up.badge.a.fill"
        case .deleteOperation:
            "square.stack.3d.up.slash.fill"
        }
    }
}

public enum StatusSubMenu: String, Equatable, Sendable, CaseIterable, Identifiable  {
    case checkStatus
    case modifyStatus

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .checkStatus:
            "person.crop.circle.badge.questionmark"
        case .modifyStatus:
            "person.crop.circle.badge.exclamationmark"
        }
    }
}

public enum PairAccountSubMenu: String, Equatable, Sendable, CaseIterable, Identifiable  {
    case pairWithToken = "With Token"
    case pairWithId = "With Id"
    
    public var id: String { rawValue }
}
