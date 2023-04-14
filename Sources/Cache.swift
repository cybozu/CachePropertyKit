import Foundation

public typealias CacheKey = String

@propertyWrapper
public struct Cache<Value: Cacheable> {
    private let key: CacheKey
    private let lifetime: Lifetime

    static private var container: CacheContainer { .shared }

    public var wrappedValue: Value? {
        get {
            guard let data: CacheContainer.CacheData<Value> = Self.container.value(forKey: key) else {
                return nil
            }

            return data.isAlive(validatedWith: lifetime) ? data.value : nil
        }
        set {
            guard let newValue = newValue else { return }

            Self.container.setValue(newValue, forKey: key)
        }
    }

    public init(key: CacheKey, lifetime: Lifetime) {
        self.key = key
        self.lifetime = lifetime
    }

    public init(wrappedValue: Value?, key: CacheKey, lifetime: Lifetime) {
        self.key = key
        self.lifetime = lifetime

        guard let wrappedValue else {
            return
        }

        Self.container.setValue(wrappedValue, forKey: key)
    }
}
