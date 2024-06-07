//
//  LSPCache.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation

struct CacheKey<ExtraData: Hashable>: Hashable {
    let uri: String
    let requestType: String
    let extraData: ExtraData?

    init(uri: String, requestType: String, extraData: ExtraData? = nil) {
        self.uri = uri
        self.requestType = requestType
        self.extraData = extraData
    }
}

final class LSPCache {
    /// Represents a single cache entry with a generic type.
    final class CacheEntry<T: Codable & Sendable>: NSObject {
        let value: T

        init(_ value: T) {
            self.value = value
        }
    }

    private var cache = NSCache<CacheKey, CacheEntry<Any>>()

    func get<T>(key: CacheKey<AnyHashable>) -> T? {
        let cacheKey = key.description as NSString
        guard let entry = cache.object(forKey: cacheKey) as? CacheEntry<T> else {
            return nil
        }
        return entry.value
    }

    func set<T>(key: CacheKey<AnyHashable>, value: T) {
        let entry = CacheEntry(value)
        let cacheKey = key.description as NSString
        cache.setObject(entry, forKey: cacheKey)
    }

    func invalidate(key: CacheKey<AnyHashable>) {
        let cacheKey = key.description as NSString
        cache.removeObject(forKey: cacheKey)
    }
}

private extension CacheKey: CustomStringConvertible {
    var description: String {
        if let extraData = extraData {
            return "\(uri)-\(requestType)-\(extraData)"
        } else {
            return "\(uri)-\(requestType)"
        }
    }
}
