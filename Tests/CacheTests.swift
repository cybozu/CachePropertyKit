import XCTest
@testable import CachePropertyKit

@MainActor // NOTE: These tests must be executed within an actor-isolated context to prevent data races, because CacheContainer is a singleton.
final class CacheTests: XCTestCase {
    override func tearDown() {
        CacheContainer.clearAll()
    }

    func test_init_wrappedValue_is_nil_when_nil_is_assigned_in_init() {
        let sut = Cache<String>(wrappedValue: nil, key: UUID().uuidString, lifetime: .duration(60))
        XCTAssertNil(sut.wrappedValue)
    }

    func test_init_wrappedValue_is_the_value_when_a_non_nil_value_is_assigned_in_init() {
        let sut = Cache<String>(wrappedValue: "value", key: UUID().uuidString, lifetime: .duration(60))
        XCTAssertEqual(sut.wrappedValue, "value")
    }

    func test_wrappedValueGet_return_nil_when_no_matching_key_exists() {
        let cacheDate = Date()
        let expiredDate = cacheDate.addingTimeInterval(3600)
        CacheContainer.shared.setValue("value", forKey: "exist.key", cacheDate: cacheDate)

        let sut = Cache<String>(key: "not.exist.key", lifetime: Lifetime(makeExpiredDate: { _ in expiredDate }))
        XCTAssertNil(sut.wrappedValue)
    }

    func test_wrappedValueGet_return_data_when_a_matching_key_exists_and_the_data_is_in_cache_period() {
        let cacheDate = Date()
        let expiredDate = cacheDate.addingTimeInterval(3600)
        CacheContainer.shared.setValue("value", forKey: "exist.key", cacheDate: cacheDate)

        let sut = Cache<String>(key: "exist.key", lifetime: Lifetime(makeExpiredDate: { _ in expiredDate }))
        XCTAssertEqual(sut.wrappedValue, "value")
    }

    func test_wrappedValueGet_return_nil_when_a_matching_key_exists_and_the_data_is_not_in_cache_period() {
        let cacheDate = Date.distantFuture
        let expiredDate = cacheDate.addingTimeInterval(3600)
        CacheContainer.shared.setValue("value", forKey: "exist.key", cacheDate: cacheDate)

        let sut = Cache<String>(key: "exist.key", lifetime: Lifetime(makeExpiredDate: { _ in expiredDate }))
        XCTAssertNil(sut.wrappedValue)
    }

    func test_wrappedValueSet_wrappedValue_does_not_changed_when_newValue_is_nil() {
        var sut = Cache<String>(wrappedValue: "value", key: UUID().uuidString, lifetime: .duration(60))
        sut.wrappedValue = nil
        XCTAssertEqual(sut.wrappedValue, "value")
    }

    func test_wrappedValueSet_wrappedValue_update_to_newValue_when_newValue_is_not_nil() {
        var sut = Cache<String>(wrappedValue: "value", key: UUID().uuidString, lifetime: .duration(60))
        sut.wrappedValue = "changed"
        XCTAssertEqual(sut.wrappedValue, "changed")
    }
}
