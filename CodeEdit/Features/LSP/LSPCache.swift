//
//  LSPCache.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation

struct NoExtraData: Hashable { }

struct CacheKey: Hashable {
    let uri: String
    let requestType: String
    let extraData: AnyHashable?

    init(uri: String, requestType: String, extraData: AnyHashable? = nil) {
        self.uri = uri
        self.requestType = requestType
        self.extraData = extraData
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
