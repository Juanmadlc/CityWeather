import Foundation
import Testing
@testable import CityWeather

struct MocksManagerTest {
    private let sut = MocksManager()

    @Test
    func `Mock mode is disabled by default`() {
        #expect(sut.shouldUseMockData() == false)
    }

    @Test
    func `Shared instance is reused`() {
        #expect(MocksManager.shared === MocksManager.shared)
    }

    @Test
    func `Weather mock resource loads nonempty data`() throws {
        let data = try sut.getMockDataWeather()

        #expect(data.isEmpty == false)
    }

    @Test
    func `Forecast mock resource loads nonempty data`() throws {
        let data = try sut.getMockDataForecast()

        #expect(data.isEmpty == false)
    }

    @Test
    func `Geocoding search mock resource loads nonempty data`() throws {
        let data = try sut.getMockGeoDataSearch()

        #expect(data.isEmpty == false)
    }
}
