import Foundation

public final class CacheContainer {
    static let shared = CacheContainer()

    public static func clearAll() {
        shared.storage.keys.forEach {
            shared.storage.removeValue(forKey: $0)
        }
    }

    public static func clearAll(where shouldBeCleared: (CacheKey) -> Bool) {
        shared.storage.keys.forEach {
            if shouldBeCleared($0) {
                shared.storage.removeValue(forKey: $0)
            }
        }
    }

    var storage: ThreadSafeDictionary<CacheKey, Data> = .init()

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

final class ThreadSafeDictionary<V: Hashable,T>: Collection {
    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue",
                                                attributes: .concurrent)

    var keys: Dictionary<V, T>.Keys {
        self.concurrentQueue.sync {
            return self.dictionary.keys
        }
    }

    var values: Dictionary<V, T>.Values {
        self.concurrentQueue.sync {
            return self.dictionary.values
        }
    }

    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }

    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }

    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }

    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }
}
