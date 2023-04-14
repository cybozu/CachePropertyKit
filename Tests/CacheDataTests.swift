import XCTest
@testable import CachePropertyKit

final class CacheDataTests: XCTestCase {
    private let startDate = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
    private let endDate = ISO8601DateFormatter().date(from: "2023-01-03T00:00:00Z")!
    private lazy var lifetime = Lifetime(makeExpiredDate: { _ in self.endDate })

    //
    //  ---|--lifetime range--|--->
    //   ^
    //   given time
    //
    func test_isAlive_return_false_when_a_time_before_a_lifetime_range_is_given() {
        let beforeStartDate = ISO8601DateFormatter().date(from: "2022-12-31T00:00:00Z")!
        let sut = CacheContainer.CacheData(value: "", cacheDate: startDate)
        XCTAssertFalse(sut.isAlive(validatedWith: lifetime, and: beforeStartDate))
    }

    //
    //  ---|--lifetime range--|--->
    //     ^
    //     given time
    //
    func test_isAlive_return_true_when_a_time_equal_to_the_lower_bound_of_a_lifetime_range_is_given() {
        let sut = CacheContainer.CacheData(value: "", cacheDate: startDate)
        XCTAssertTrue(sut.isAlive(validatedWith: lifetime, and: startDate))
    }

    //
    //  ---|--lifetime range--|--->
    //          ^
    //          given time
    //
    func test_isAlive_return_true_when_a_time_within_a_lifetime_range_is_given() {
        let betweenRange = ISO8601DateFormatter().date(from: "2023-01-02T00:00:00Z")!
        let sut = CacheContainer.CacheData(value: "", cacheDate: startDate)
        XCTAssertTrue(sut.isAlive(validatedWith: lifetime, and: betweenRange))
    }

    //
    //  ---|--lifetime range--|--->
    //                        ^
    //                        given time
    //
    func test_isAlive_return_true_when_a_time_equal_to_the_upper_bound_of_a_lifetime_range_is_given() {
        let sut = CacheContainer.CacheData(value: "", cacheDate: startDate)
        XCTAssertTrue(sut.isAlive(validatedWith: lifetime, and: endDate))
    }

    //
    //  ---|--lifetime range--|--->
    //                          ^
    //                          given time
    //
    func test_isAlive_return_false_when_a_time_after_a_lifetime_range_is_given() {
        let afterEndDate = ISO8601DateFormatter().date(from: "2023-01-04T00:00:00Z")!
        let sut = CacheContainer.CacheData(value: "", cacheDate: startDate)
        XCTAssertFalse(sut.isAlive(validatedWith: lifetime, and: afterEndDate))
    }
}
