import Foundation

public final class CacheContainer {
    static let shared = CacheContainer()

    public static func clearAll() {
        shared.storage.forEach { (key, _) in
            shared.storage.removeValue(forKey: key)
        }
    }

    public static func clearAll(where shouldBeCleared: (CacheKey) -> Bool) {
        shared.storage.forEach { (key, _) in
            if shouldBeCleared(key) {
                shared.storage.removeValue(forKey: key)
            }
        }
    }

    var storage: [CacheKey : Data] = [:]

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    func setValue<Value: Cacheable>(_ value: Value, forKey key: CacheKey, cacheDate: Date = .now) {
        let data = try? encoder.encode(CacheData(value: value, cacheDate: cacheDate))
        storage[key] = data
    }

    func value<Value: Cacheable>(forKey key: CacheKey) -> CacheData<Value>? {
        guard let data = storage[key] else {
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
