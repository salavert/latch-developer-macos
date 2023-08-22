import Foundation

enum LogTab: String, CaseIterable, Identifiable {
    case request = "Request"
    case response = "Response"
    
    public var id: String { rawValue }
}
