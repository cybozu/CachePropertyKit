import XCTest
@testable import CachePropertyKit

@MainActor // NOTE: These tests must be executed within an actor-isolated context to prevent data races, because CacheContainer is a singleton.
final class CacheContainerTests: XCTestCase {
    private let sut = CacheContainer.shared

    override func tearDown() {
        CacheContainer.clearAll()
    }

    func test_clearAll_remove_all_stored_caches() {
        sut.setValue("value1", forKey: "key.value1")
        sut.setValue(2, forKey: "key.value2")
        sut.setValue(true, forKey: "key.value3")

        CacheContainer.clearAll()
        XCTAssertTrue(sut.storage.isEmpty)
    }

    func test_clearAllWhere_remove_only_specified_caches() {
        sut.setValue("value1", forKey: "key.value1")
        sut.setValue(2, forKey: "key.value2")
        sut.setValue(true, forKey: "key.value3")

        CacheContainer.clearAll(where: { $0 == "key.value1" })
        XCTAssertEqual(sut.storage.keys.sorted(), ["key.value2", "key.value3"])
    }

    func test_value_return_nil_when_a_non_cached_key_is_given() {
        let data: CacheContainer.CacheData<String>? = sut.value(forKey: "not.exist.key")
        XCTAssertNil(data)
    }

    func test_value_return_the_CacheData_when_a_cached_key_is_given() {
        let cacheDate = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        sut.setValue("value", forKey: "key.value", cacheDate: cacheDate)
        let data: CacheContainer.CacheData<String>? = sut.value(forKey: "key.value")
        XCTAssertEqual(data, .init(value: "value", cacheDate: cacheDate))
    }
}

extension CacheContainer.CacheData<String>: Equatable {
    public static func == (lhs: CacheContainer.CacheData<String>, rhs: CacheContainer.CacheData<String>) -> Bool {
        lhs.value == rhs.value && lhs.cacheDate == rhs.cacheDate
    }
}

