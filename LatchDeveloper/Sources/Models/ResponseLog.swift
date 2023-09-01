import Foundation
import LatchSharedModels

public struct ResponseLog: Equatable, Hashable {
    let date: Date
    let response: LatchResponse
}

extension ResponseLog: Identifiable {
    public var id: Double {
        date.timeIntervalSince1970
    }
}

extension ResponseLog {
    public var responseStatusCode: Int? {
        response.httpResponse?.statusCode
    }
        
    public var responseBodyStatusCode: Int? {
        if let dictionary = try? JSONSerialization.jsonObject(with: response.rawData, options: []) as? [String: Any],
            let error = dictionary["error"] as? [String: Any],
            let code = error["code"] as? Int {
            return code
        } else {
            return nil
        }
    }
    
    public var responseBodyErrorMessage: String? {
        if let dictionary = try? JSONSerialization.jsonObject(with: response.rawData, options: []) as? [String: Any],
            let error = dictionary["error"] as? [String: Any],
            let message = error["message"] as? String {
            return message
        } else {
            return nil
        }
    }
    
    public var requestDescription: String {
        var output = ""
        if let httpMethod = response.request.httpMethod,  let url = response.request.url {
            output += "[\(httpMethod)] \(url)\n\n"
        }
        if let httpBody = response.request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
            output += "[BODY]\n\(httpBodyString)\n\n"
        }
        output += "[HEADERS]\n\(response.request.allHTTPHeaderFields?.description ?? "{}")\n\n"
        return output
    }
    
    public var responseDescription: String {
        if let httpResponse = response.httpResponse, let url = httpResponse.url {
            return """
            [\(httpResponse.statusCode)] \(url)
            
            [BODY]
            \(response.rawData.prettyPrintedJSONString)
            
            [HEADERS]
            \(httpResponse.allHeaderFields.description)
            """
        } else {
            return response.rawData.prettyPrintedJSONString
        }
    }
}
