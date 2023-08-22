import Foundation

extension Data {
    func decodeAs<T>(_ type: T.Type) -> T? where T : Decodable {
        do {
            return try JSONDecoder().decode(type,from: self)
        } catch {
            return nil
        }
    }
    
    var prettyPrintedJSONString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }
        return prettyPrintedString.description
    }
}
