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

final class ThreadSafeDictionary<V: Hashable, T>: Collection {
    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue", attributes: .concurrent)

    var keys: Dictionary<V, T>.Keys {
        concurrentQueue.sync { dictionary.keys }
    }

    var values: Dictionary<V, T>.Values {
        concurrentQueue.sync { dictionary.values }
    }

    var startIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync { dictionary.startIndex }
    }

    var endIndex: Dictionary<V, T>.Index {
        concurrentQueue.sync { dictionary.endIndex }
    }

    init(dictionary: [V : T] = [:]) {
        self.dictionary = dictionary
    }

    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        concurrentQueue.sync { dictionary.index(after: i) }
    }

    subscript(key: V) -> T? {
        set(newValue) {
            concurrentQueue.async(flags: .barrier) { [weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            concurrentQueue.sync { dictionary[key] }
        }
    }

    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        concurrentQueue.sync { dictionary[index] }
    }

    func removeValue(forKey key: V) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }
}
