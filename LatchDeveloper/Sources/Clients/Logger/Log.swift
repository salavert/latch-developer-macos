import Foundation

public enum Log {
    private static let syncQueue = DispatchQueue(label: "com.telefonica.latchdeveloper.logger")
    private static var isEnabled = false
    private static var subsystem = Subsystem.value
    private static var minLevel = LogLevel.trace
    private static var loggers: [LogLogger] = []
    private static var disabledCategories: Set<LogCategory> = []
}

// MARK: Public

public extension Log {
    static func trace(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.trace, category, message) }
    }

    static func debug(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.debug, category, message) }
    }

    static func info(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.info, category, message) }
    }

    static func notice(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.notice, category, message) }
    }

    static func `default`(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.default, category, message) }
    }

    static func warning(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.warning, category, message) }
    }

    static func error(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.error, category, message) }
    }

    static func fault(_ category: LogCategory, _ message: StringLiteralType) {
        syncQueue.sync { log(.fault, category, message) }
    }

    static func disable(category: LogCategory) {
        _ = syncQueue.sync { disabledCategories.insert(category) }
    }

    static func enable(category: LogCategory) {
        _ = syncQueue.sync { disabledCategories.remove(category) }
    }

    static func add(logger: LogLogger) {
        syncQueue.sync { loggers.append(logger) }
    }

    static func enable() {
        syncQueue.sync { isEnabled = true }
    }

    static func disable() {
        syncQueue.sync { isEnabled = false }
    }

    static func set(minLevel level: LogLevel) {
        syncQueue.sync { minLevel = level }
    }
}

// MARK: Private

private extension Log {
    static func log(_ level: LogLevel, _ category: LogCategory, _ message: StringLiteralType) {
        guard isEnabled else { return }

        guard level >= minLevel else {
            return
        }

        guard !disabledCategories.contains(category) else {
            return
        }

        let logger = category.logger(subsystem: subsystem)
        logger.log(level: level, message: message)

        let message = LogMessage(date: Date(), level: level, category: category, message: message)
        for logger in loggers {
            logger.log(message)
        }
    }
}

// MARK: LogLogger

public protocol LogLogger {
    func log(_ message: LogMessage)
}

// MARK: Helpers

private class Subsystem {
    static var value: String {
        Bundle(for: Subsystem.self).bundleIdentifier!
    }
}
