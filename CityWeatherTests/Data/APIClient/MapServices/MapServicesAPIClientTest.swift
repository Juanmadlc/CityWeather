//
//  MapServicesAPIClientTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

struct MapServicesAPIClientTest {
    @Test
    func `Weather request decodes a valid response`() async throws {
        let sut = MapServicesAPIClient(
            network: StubMapServicesNetwork(
                weatherResponse: .data(validWeatherData),
                forecastResponse: .failure
            )
        )

        let weather = try await sut.getDataWeather(city: "Granada")

        #expect(weather.name == "Granada")
        #expect(weather.cod == 200)
        #expect(weather.coord.lat == 37.25)
        #expect(weather.coord.lon == -3.25)
        #expect(weather.weather.first?.main == "Clouds")
    }

    @Test
    func `Forecast request decodes a valid response`() async throws {
        let sut = MapServicesAPIClient(
            network: StubMapServicesNetwork(
                weatherResponse: .failure,
                forecastResponse: .data(validForecastData)
            )
        )

        let forecast = try await sut.getDataForecast(city: "Granada")

        #expect(forecast.cod == "200")
        #expect(forecast.cnt == 0)
        #expect(forecast.list.isEmpty)
        #expect(forecast.city.name == "Granada")
        #expect(forecast.city.country == "ES")
    }

    @Test
    func `Weather request propagates the network error`() async {
        let sut = MapServicesAPIClient(
            network: StubMapServicesNetwork(
                weatherResponse: .failure,
                forecastResponse: .data(validForecastData)
            )
        )

        await #expect(throws: TestError.expected) {
            _ = try await sut.getDataWeather(city: "Granada")
        }
    }

    @Test
    func `Forecast request throws when the response is not valid JSON`() async {
        let sut = MapServicesAPIClient(
            network: StubMapServicesNetwork(
                weatherResponse: .data(validWeatherData),
                forecastResponse: .data(Data("invalid JSON".utf8))
            )
        )

        await #expect(throws: DecodingError.self) {
            _ = try await sut.getDataForecast(city: "Granada")
        }
    }

    private var validWeatherData: Data {
        Data(
            """
            {
                "coord": { "lon": -3.25, "lat": 37.25 },
                "weather": [{
                    "id": 801,
                    "main": "Clouds",
                    "description": "Scattered clouds",
                    "icon": "02d"
                }],
                "base": "stations",
                "main": {
                    "temp": 32.39,
                    "feels_like": 30.2,
                    "temp_min": 32.39,
                    "temp_max": 32.39,
                    "pressure": 1021,
                    "humidity": 17
                },
                "wind": { "speed": 3.12, "deg": 28 },
                "clouds": { "all": 17 },
                "dt": 1788795664,
                "sys": {
                    "country": "ES",
                    "sunrise": 1788760107,
                    "sunset": 1788806048
                },
                "timezone": 7200,
                "id": 2517115,
                "name": "Granada",
                "cod": 200
            }
            """.utf8
        )
    }

    private var validForecastData: Data {
        Data(
            """
            {
                "cod": "200",
                "message": 0,
                "cnt": 0,
                "list": [],
                "city": {
                    "id": 2517115,
                    "name": "Granada",
                    "coord": { "lon": -3.25, "lat": 37.25 },
                    "country": "ES",
                    "population": 907428,
                    "timezone": 7200,
                    "sunrise": 1788760107,
                    "sunset": 1788806048
                }
            }
            """.utf8
        )
    }
}

private struct StubMapServicesNetwork: MapServicesNetworkProtocol {
    enum Response: Sendable {
        case data(Data)
        case failure
    }

    let weatherResponse: Response
    let forecastResponse: Response

    func getDataWeather(city: String) async throws -> Data {
        try data(for: weatherResponse)
    }

    func getDataForecast(city: String) async throws -> Data {
        try data(for: forecastResponse)
    }

    private func data(for response: Response) throws -> Data {
        switch response {
        case let .data(data):
            return data
        case .failure:
            throw TestError.expected
        }
    }
}

private enum TestError: Error {
    case expected
}
