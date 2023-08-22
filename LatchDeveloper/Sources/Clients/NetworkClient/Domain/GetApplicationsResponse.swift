import Foundation

public struct GetApplicationsResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let operations: [String: Operation]?
    }
    
    public struct Operation: Decodable, Equatable, Hashable {
        let secret: String?
        let contactEmail: String?
        let twoFactor: String
        let imageUrl: String?
        let contactPhone: String?
        let lockOnRequest: String
        let name: String
        let operations: [String: Operation]?
        
        public enum CodingKeys: String, CodingKey {
            case secret
            case contactEmail
            case twoFactor = "two_factor"
            case imageUrl
            case contactPhone
            case lockOnRequest = "lock_on_request"
            case name
            case operations
        }
    }
}
