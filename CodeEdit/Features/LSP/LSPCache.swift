//
//  LSPCache.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation

struct CacheKey: Hashable {
    let uri: String
    let requestType: String
}

// TODO: SWITCH TO DOUBLY LINK LIST

/// Thread safe implementation for caching LSP requests with time based expiration and cache size limits.
class LSPCache {
    /// Represents a single cache entry with a generic type and an expiration date.
    private struct CacheEntry<T> {
        let value: T
        let expirationDate: Date
    }

    /// The main cache storage mapping a `CacheKey` to a generic value.
    private var cache = [CacheKey: Any]()
    /// A collection of locks, one per cache key, for thread-safe access to cache entries.
    /// `DispatchQueue` is used for synchronization to ensure that cache operations are thread-safe.
    private var locks = [CacheKey: DispatchQueue]()
    /// The maximum number of entries that the cache can hold.
    private var cacheSizeLimit: Int
    /// Tracks the order of cache keys for potential eviction.
    private var cacheEntriesOrder: [CacheKey] = []
    /// Queue for handling the eviction of old cache entries. Separated from main cache operations to not block them.
    private let evictionQueue = DispatchQueue(label: "com.CodeEdit.LSPCache.evictionQueue")

    init(cacheSizeLimit: Int = 100) {
        self.cacheSizeLimit = cacheSizeLimit
    }

    private func lock(for key: CacheKey) -> DispatchQueue {
        if let lock = locks[key] {
            return lock
        } else {
            let newLock = DispatchQueue(label: "com.CodeEdit.LSPCache.lock.\(key)")
            locks[key] = newLock
            return newLock
        }
    }

    func get<T>(key: CacheKey) -> T? {
        var result: T?
        lock(for: key).sync {  // Sync to ensure thread safe access
            guard let entry = cache[key] as? CacheEntry<T>, Date() < entry.expirationDate else { return }
            result = entry.value
        }
        return result
    }

    func set<T>(key: CacheKey, value: T, withExpiry expiry: TimeInterval = 300) {
        lock(for: key).async {
            let expirationDate = Date().addingTimeInterval(expiry)
            let entry = CacheEntry(value: value, expirationDate: expirationDate)
            self.cache[key] = entry
        }
        scheduleEviction()
    }

    func invalidate(key: CacheKey) {
        lock(for: key).async {
            self.cache.removeValue(forKey: key)
        }
    }

    private func scheduleEviction() {
        // TODO: DECIDE ON EVICTION INTERVAL
        evictionQueue.asyncAfter(deadline: .now() + 10) {
            self.evictIfNeeded()
        }
    }
    
    private func evictIfNeeded() {
        evictionQueue.async(flags: .barrier) {
            while self.cacheEntriesOrder.count > self.cacheSizeLimit {
                if let oldestKey = self.cacheEntriesOrder.first {
                    self.cache.removeValue(forKey: oldestKey)
                    self.cacheEntriesOrder.removeFirst()
                }
            }
        }
    }
}
