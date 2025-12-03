import Foundation
import os

public final class CacheContainer: Sendable {
    static let shared = CacheContainer()

    public static func clearAll() {
        shared.storage.withLock { storage in
            storage.keys.forEach {
                storage.removeValue(forKey: $0)
            }
        }
    }

    public static func clearAll(where shouldBeCleared: @Sendable (CacheKey) -> Bool) {
        shared.storage.withLock { storage in
            storage.keys.forEach {
                if shouldBeCleared($0) {
                    storage.removeValue(forKey: $0)
                }
            }
        }
    }

    let storage = OSAllocatedUnfairLock<[CacheKey : Data]>(initialState: [:])

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    func setValue<Value: Cacheable>(_ value: Value, forKey key: CacheKey, cacheDate: Date = .now) {
        let data = try? encoder.encode(CacheData(value: value, cacheDate: cacheDate))
        storage.withLock { $0[key] = data }
    }

    func value<Value: Cacheable>(forKey key: CacheKey) -> CacheData<Value>? {
        guard let data = storage.withLock(\.[key]) else {
            return nil
        }

        return try? decoder.decode(CacheData<Value>.self, from: data)
    }

    struct CacheData<Value: Cacheable>: Cacheable {
        let value: Value
        let cacheDate: Date

        func isAlive(validatedWith lifetime: Lifetime, and currentDate: Date = .now) -> Bool {
            return lifetime.range(from: cacheDate).contains(currentDate)
        }
    }
}
