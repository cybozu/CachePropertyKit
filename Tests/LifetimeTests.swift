import XCTest
@testable import CachePropertyKit

final class LifetimeTests: XCTestCase {
    private let dateFormatter = ISO8601DateFormatter()

    func test_duration_range_return_a_range_from_the_given_date_to_the_given_date_plus_seconds() {
        let currentDate = dateFormatter.date(from: "2023-01-01T00:00:00Z")!
        let endDate = dateFormatter.date(from: "2023-01-01T01:00:00Z")!
        let sut = Lifetime.duration(3600)

        let result = sut.range(from: currentDate)
        let expect = (currentDate...endDate)

        XCTAssertEqual(result, expect)
    }

    func test_until_range_return_a_range_from_the_given_date_to_the_date_specified_by_the_until_parameter() {
        let startDate = dateFormatter.date(from: "2023-01-01T00:00:00Z")!
        let endDate = dateFormatter.date(from: "2023-01-02T00:00:00Z")!
        let sut = Lifetime.until(endDate)

        let result = sut.range(from: startDate)
        let expect = (startDate...endDate)

        XCTAssertEqual(result, expect)
    }
}
