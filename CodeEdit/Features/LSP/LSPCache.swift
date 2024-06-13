//
//  LSPCache.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation

struct AnyHashableData: Hashable {
    private let value: Any
    private let hashValueFunc: () -> Int
    private let equalsFunc: (Any) -> Bool

    init<T: Hashable>(_ value: T) {
        self.value = value
        self.hashValueFunc = { value.hashValue }
        self.equalsFunc = { ($0 as? T) == value }
    }

    static func == (lhs: AnyHashableData, rhs: AnyHashableData) -> Bool {
        return lhs.equalsFunc(rhs.value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValueFunc())
    }

    var description: String {
        return String(describing: value)
    }
}

struct NoExtraData: Hashable { }

struct CacheKey: Hashable {
    let uri: String
    let requestType: String
    let extraData: AnyHashableData?

    init<ExtraData: Hashable>(uri: String, requestType: String, extraData: ExtraData? = nil) {
        self.uri = uri
        self.requestType = requestType
        self.extraData = extraData.map(AnyHashableData.init)
    }

    static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
        return lhs.uri == rhs.uri &&
            lhs.requestType == rhs.requestType &&
            lhs.extraData == rhs.extraData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
        hasher.combine(requestType)
        if let extraData = extraData {
            hasher.combine(extraData)
        }
    }
}

final class LSPCache {
    /// Represents a single cache entry with a generic type.
    final class CacheEntry: NSObject {
        let value: Any
        let type: Any.Type

        init<T: Codable & Sendable>(_ value: T) {
            self.value = value
            self.type = T.self
        }

        func getValue<T: Codable & Sendable>(as type: T.Type) -> T? {
            return value as? T
        }
    }

    private var cache = NSCache<NSString, CacheEntry>()

    func get<T: Codable & Sendable>(key: CacheKey, as type: T.Type) -> T? {
        let cacheKey = key.description as NSString
        guard let entry = cache.object(forKey: cacheKey) else {
            return nil
        }
        return entry.getValue(as: type)
    }

    func set<T: Codable & Sendable>(key: CacheKey, value: T) {
        let entry = CacheEntry(value)
        let cacheKey = key.description as NSString
        cache.setObject(entry, forKey: cacheKey)
    }

    func invalidate(key: CacheKey) {
        let cacheKey = key.description as NSString
        cache.removeObject(forKey: cacheKey)
    }
}

extension CacheKey: CustomStringConvertible {
    var description: String {
        if let extraData = extraData {
            return "\(uri)-\(requestType)-\(extraData)"
        } else {
            return "\(uri)-\(requestType)"
        }
    }
}
