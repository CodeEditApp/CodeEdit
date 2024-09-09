//
//  LSPCache.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation

class LSPCache {
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
