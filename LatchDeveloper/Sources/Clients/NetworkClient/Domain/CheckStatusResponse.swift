import Foundation

public struct CheckStatusResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let operations: [String: Operation]?
    }

    public struct Operation: Decodable, Equatable, Hashable {
        let status: OperationStatus
    }

    public enum OperationStatus: String, Decodable, Equatable, Hashable {
        case on
        case off
    }
}
