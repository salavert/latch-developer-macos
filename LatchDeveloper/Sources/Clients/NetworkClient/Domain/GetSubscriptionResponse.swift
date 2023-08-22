import Foundation

public struct GetSubscriptionResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let subscription: Subscription
    }
    
    public struct Subscription: Decodable, Equatable, Hashable {
        let id: String
        let users: Quota
        let operations: [String: Quota]
        let applications: Quota
    }
    
    public struct Quota: Decodable, Equatable, Hashable {
        let inUse: Int
        let limit: Int
    }

}
