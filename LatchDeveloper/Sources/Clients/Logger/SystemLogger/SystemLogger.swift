import Foundation
import OSLog

protocol SystemLogger {
    func log(level: LogLevel, message: String)
}

// MARK: Logger

extension Logger: SystemLogger {
    func log(level: LogLevel, message: String) {
        switch level {
        case .trace:
            trace("\(message, privacy: .public)")
        case .debug:
            debug("\(message, privacy: .public)")
        case .info:
            info("\(message, privacy: .public)")
        case .notice:
            notice("\(message, privacy: .public)")
        case .warning:
            warning("\(message, privacy: .public)")
        case .error:
            error("\(message, privacy: .public)")
        case .fault:
            fault("\(message, privacy: .public)")
        case .default:
            log("\(message, privacy: .public)")
        }
    }
}
