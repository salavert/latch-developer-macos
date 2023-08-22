import Foundation

public struct UserDefaultsClient {
    public enum Domain: String, CaseIterable {
        /// Domain dedicated to the current user.
        case user
        /// Domain dedicated to the app running, multiple user may use this domain.
        case app
        /// Domain dedicated to store developer settings .
        case developer

        var value: String {
            "com.tef.\(rawValue)"
        }
    }

    public struct Key<Value>: CustomStringConvertible {
        let domain: Domain
        let rawValue: String

        public init(_ rawValue: String, domain: Domain = .user) {
            self.domain = domain
            self.rawValue = rawValue
        }

        public var value: String {
            "\(domain.value).\(rawValue)"
        }

        public var description: String {
            value
        }
    }

    private var boolForKey: (Key<Bool>) -> Bool?
    private var stringForKey: (Key<String>) -> String?
    private var stringArrayForKey: (Key<[String]>) -> [String]?
    private var dataForKey: (Key<Data>) -> Data?
    private var dictionaryForKey: (Key<[String : Any]>) -> [String : Any]?
    private var doubleForKey: (Key<Double>) -> Double?
    private var integerForKey: (Key<Int>) -> Int?
    private var setBool: (Key<Bool>, Bool?) -> Void
    private var setString: (Key<String>, String?) -> Void
    private var setStringArray: (Key<[String]>, [String]?) -> Void
    private var setData: (Key<Data>, Data?) -> Void
    private var setDictionary: (Key<[String : Any]>, [String : Any]?) -> Void
    private var setDouble: (Key<Double>, Double?) -> Void
    private var setInteger: (Key<Int>, Int?) -> Void
    private var clear: (Domain) -> Void

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public init(
        boolForKey: @escaping (UserDefaultsClient.Key<Bool>) -> Bool?,
        stringForKey: @escaping (UserDefaultsClient.Key<String>) -> String?,
        stringArrayForKey: @escaping (UserDefaultsClient.Key<[String]>) -> [String]?,
        dataForKey: @escaping (UserDefaultsClient.Key<Data>) -> Data?,
        dictionaryForKey: @escaping (UserDefaultsClient.Key<[String : Any]>) -> [String : Any]?,
        doubleForKey: @escaping (UserDefaultsClient.Key<Double>) -> Double?,
        integerForKey: @escaping (UserDefaultsClient.Key<Int>) -> Int?,
        setBool: @escaping (UserDefaultsClient.Key<Bool>, Bool?) -> Void,
        setString: @escaping (UserDefaultsClient.Key<String>, String?) -> Void,
        setStringArray: @escaping (UserDefaultsClient.Key<[String]>, [String]?) -> Void,
        setData: @escaping (UserDefaultsClient.Key<Data>, Data?) -> Void,
        setDictionary: @escaping (UserDefaultsClient.Key<[String : Any]>, [String : Any]?) -> Void,
        setDouble: @escaping (UserDefaultsClient.Key<Double>, Double?) -> Void,
        setInteger: @escaping (UserDefaultsClient.Key<Int>, Int?) -> Void,
        clear: @escaping (UserDefaultsClient.Domain) -> Void
    ) {
        self.boolForKey = boolForKey
        self.stringForKey = stringForKey
        self.stringArrayForKey = stringArrayForKey
        self.dataForKey = dataForKey
        self.dictionaryForKey = dictionaryForKey
        self.doubleForKey = doubleForKey
        self.integerForKey = integerForKey
        self.setBool = setBool
        self.setString = setString
        self.setStringArray = setStringArray
        self.setData = setData
        self.setDictionary = setDictionary
        self.setDouble = setDouble
        self.setInteger = setInteger
        self.clear = clear
    }

    public func set(_ value: Int?, forKey key: Key<Int>) {
        setInteger(key, value)
    }

    public func set(_ value: Double?, forKey key: Key<Double>) {
        setDouble(key, value)
    }

    public func set(_ value: String?, forKey key: Key<String>) {
        setString(key, value)
    }
    
    public func set(_ value: [String]?, forKey key: Key<[String]>) {
        setStringArray(key, value)
    }

    public func set(_ value: Data?, forKey key: Key<Data>) {
        setData(key, value)
    }

    public func set(_ value: [String : Any]?, forKey key: Key<[String : Any]>) {
        setDictionary(key, value)
    }

    public func set(_ value: Bool?, forKey key: Key<Bool>) {
        setBool(key, value)
    }

    public func value(forKey key: Key<Int>) -> Int? {
        integerForKey(key)
    }

    public func value(forKey key: Key<Double>) -> Double? {
        doubleForKey(key)
    }

    public func value(forKey key: Key<String>) -> String? {
        stringForKey(key)
    }

    public func value(forKey key: Key<[String]>) -> [String]? {
        stringArrayForKey(key)
    }

    public func value(forKey key: Key<[String : Any]>) -> [String : Any]? {
        dictionaryForKey(key)
    }

    public func value(forKey key: Key<Data>) -> Data? {
        dataForKey(key)
    }

    public func value(forKey key: Key<Bool>) -> Bool? {
        boolForKey(key)
    }

    public func retrieve<Value: Decodable>(_ key: Key<Value>) -> Value? {
        guard let data = dataForKey(.init(key.value, domain: key.domain)) else {
            return nil
        }

        do {
            return try jsonDecoder.decode(Value.self, from: data)
        } catch {
            Log.error(.userDefaultsClient, "Cannot decode \(key)\nError: \(error)")
            return nil
        }
    }

    public func store<Value: Encodable>(_ key: Key<Value>, _ value: Value?) {
        let key = Key<Data>(key.value, domain: key.domain)

        guard let value = value else {
            setData(key, nil)
            return
        }

        do {
            let data = try jsonEncoder.encode(value)
            setData(key, data)
        } catch {
            Log.error(.userDefaultsClient, "Cannot encode \(key) with object \(value)\nError: \(error)")
        }
    }

    public func clear(domain: Domain) {
        clear(domain)
    }

    public func clearAll() {
        Domain.allCases.forEach(clear)
    }
}

// MARK: Log

public extension LogCategory {
    static let userDefaultsClient = LogCategory("UserDefaultsClient")
}
