import Foundation

extension Dictionary {
    public var description: String {
        String(
            data: try! JSONSerialization.data(
                withJSONObject: self,
                options: .prettyPrinted
            ),
            encoding: .utf8
        )!
    }
}

