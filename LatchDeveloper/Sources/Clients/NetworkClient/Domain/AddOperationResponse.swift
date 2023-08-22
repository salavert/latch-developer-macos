import Foundation

public struct AddOperationResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let operationId: String
    }
}
