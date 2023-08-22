import Foundation

public struct GenericResponseWithError: Decodable, Equatable, Hashable {
    let error: ResponseError?
}

public struct ResponseError: Decodable, Equatable, Hashable {
    let code: Int
    let message: String
}
