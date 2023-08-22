import Foundation
import OSLog

public struct LogCategory: Hashable, Equatable {
    public var value: String

    public init(_ value: String) {
        self.value = value
    }

    func logger(subsystem: String) -> SystemLogger {
        Logger(subsystem: subsystem, category: value)
    }
}

public extension LogCategory {
    static let app = LogCategory("App")
}
