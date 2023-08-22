import Foundation

public struct PairAccountResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let accountId: String
    }
}
