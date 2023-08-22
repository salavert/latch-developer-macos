import Foundation

public struct LogMessage: Equatable, Hashable, Identifiable {
    public let date: Date
    public let level: LogLevel
    public let category: LogCategory
    public let message: StringLiteralType

    public var id: Int { hashValue }

    public init(
        date: Date,
        level: LogLevel,
        category: LogCategory,
        message: StringLiteralType
    ) {
        self.date = date
        self.level = level
        self.category = category
        self.message = message
    }
}
