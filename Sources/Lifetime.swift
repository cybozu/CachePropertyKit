import Foundation

public struct Lifetime {
    private let makeExpiredDate: (Date) -> Date

    public static func duration(_ timeInterval: TimeInterval) -> Self {
        Self(makeExpiredDate: { fromDate in fromDate.addingTimeInterval(timeInterval) })
    }

    public static func until(_ date: Date) -> Self {
        Self(makeExpiredDate: { _ in date })
    }

    init(makeExpiredDate: @escaping (Date) -> Date) {
        self.makeExpiredDate = makeExpiredDate
    }

    func range(from date: Date) -> ClosedRange<Date> {
        return (date...makeExpiredDate(date))
    }
}
