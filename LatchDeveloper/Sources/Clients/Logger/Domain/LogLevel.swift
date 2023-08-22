import Foundation

public enum LogLevel: String, Comparable, CaseIterable {
    case trace, debug, info, notice, `default`, warning, error, fault

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }

    var value: Int {
        // Priority order
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .default:
            return 4
        case .warning:
            return 5
        case .error:
            return 6
        case .fault:
            return 7
        }
    }
}
