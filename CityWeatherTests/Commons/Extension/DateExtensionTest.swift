import Foundation
import Testing
@testable import CityWeather

struct DateExtensionTest {
    @Test
    func `Simple date format uses day month and year`() throws {
        let date = try #require(
            Calendar.current.date(
                from: DateComponents(year: 2026, month: 3, day: 6, hour: 12)
            )
        )

        #expect(date.toString() == "06/03/2026")
    }

    @Test
    func `Emission date formatter parses emission date`() {
        let date = DateFormatter.emissionDateFormatter.date(
            from: "2026-03-06T12:30:45.123+0000"
        )

        #expect(date != nil)
    }
}
