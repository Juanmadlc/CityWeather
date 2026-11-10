//
//  MockMapServicesAPIClientTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 10/11/2026.
//

import Testing
@testable import CityWeather

struct MockMapServicesAPIClientTest {
    private let sut = MockMapServicesAPIClient()

    @Test
    func `Weather request decodes the weather mock fixture`() async throws {
        let weather = try await sut.getDataWeather(city: "Granada")

        #expect(weather.name == "Granada")
        #expect(weather.cod == 200)
        #expect(weather.coord.lat == 37.25)
        #expect(weather.coord.lon == -3.25)
        #expect(weather.weather.count == 1)
        #expect(weather.weather.first?.main == "Clouds")
    }

    @Test
    func `Forecast request decodes the forecast mock fixture`() async throws {
        let forecast = try await sut.getDataForecast(city: "Granada")

        #expect(forecast.cod == "200")
        #expect(forecast.cnt == 40)
        #expect(forecast.city.name == "Granada")
        #expect(forecast.city.country == "ES")
        #expect(forecast.list.count == 40)
        #expect(forecast.list.first?.weather.first?.main == "Clouds")
    }
}
