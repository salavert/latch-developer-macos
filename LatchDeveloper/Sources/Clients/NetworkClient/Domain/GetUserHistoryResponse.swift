import Foundation

public struct GetUserHistoryResponse: Decodable, Equatable, Hashable {
    let error: ResponseError?
    let data: ResponseData?
    
    public struct ResponseData: Decodable, Equatable, Hashable {
        let history: [History]
        let clientVersion: [ClientVersion]
        let count: Int
        let lastSeen : Int
    }
    
    public struct History: Decodable, Equatable, Hashable {
        let action: String
        let t: Int
        let what: String
        let was: String?
        let value: String
        let userAgent: String
        let name: String
        let ip: String
    }
    
    public struct ClientVersion: Decodable, Equatable, Hashable {
        let platform: String
        let app: String
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

//{
//  "data" : {
//    "history" : [
//      {
//        "action" : "USER_UPDATE",
//        "t" : 1690281434175,
//        "what" : "status",
//        "was" : "on",
//        "value" : "off",
//        "userAgent" : "Latch\/3.4.0 (com.telefonica.latch.enterprise; build:30; iOS 16.4.0) Alamofire\/3.4.0",
//        "name" : "Test App",
//        "ip" : "188.26.218.111"
//      },
//    ],
//    "clientVersion" : [
//      {
//        "platform" : "iOS",
//        "app" : "3.4.0"
//      }
//    ],
//    "count" : 114,
//    "lastSeen" : 1692352455026,
//    "nRtj8te3quNZKWeCmJZq" : {
//      "status" : "on",
//      "contactEmail" : "",
//      "lock_on_request" : "DISABLED",
//      "operations" : {
//        "kw2UmTZwJ3xDHFnemBaz" : {
//          "status" : "off",
//          "customName" : "",
//          "skipPush" : true,
//          "two_factor" : "DISABLED",
//          "autoclose" : "180",
//          "lock_on_request" : "DISABLED",
//          "name" : "My sub operation",
//          "operations" : {
//            "Qzigsx3wrpQNEJgifJJY" : {
//              "status" : "on",
//              "two_factor" : "DISABLED",
//              "lock_on_request" : "DISABLED",
//              "operations" : {
//                "XhykmA8BpbdmRfLHvGMB" : {
//                  "status" : "on",
//                  "two_factor" : "DISABLED",
//                  "lock_on_request" : "DISABLED",
//                  "operations" : {
//                    "TXwBV3GPqmgfPNUyiYdJ" : {
//                      "status" : "on",
//                      "two_factor" : "DISABLED",
//                      "lock_on_request" : "DISABLED",
//                      "operations" : {
//
//                      },
//                      "name" : "sub opp 5"
//                    }
//                  },
//                  "name" : "sub opp 4"
//                }
//              },
//              "name" : "sub app 3"
//            }
//          }
//        }
//      },
//      "pairedOn" : 1692341452730,
//      "two_factor" : "DISABLED",
//      "contactPhone" : "",
//      "description" : "",
//      "statusLastModified" : 1692345481925,
//      "name" : "Test App",
//      "imageURL" : "https:\/\/latchstorage.blob.core.windows.net\/pro-custom-images\/avatar8.jpg"
//    }
//  }
//}
