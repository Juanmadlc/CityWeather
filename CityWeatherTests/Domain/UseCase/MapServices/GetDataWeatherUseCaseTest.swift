//
//  GetDataWeatherUseCaseTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 20/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

@Suite
struct GetDataWeatherUseCaseTest {

    @Test
    func `Execute requests only the current weather for the given city`() async throws {
        let repository = MockMapServicesRepository(weatherResult: .success(try weatherFixture()))
        let sut = GetDataWeatherUseCase(modelProtocol: repository, city: "Madrid,ES")

        _ = try await sut.execute()

        #expect(repository.weatherRequestedCities == ["Madrid,ES"])
        #expect(repository.forecastRequestedCities.isEmpty)
    }

    @Test
    func `Execute returns the weather provided by the repository`() async throws {
        let fixture = try weatherFixture()
        let repository = MockMapServicesRepository(weatherResult: .success(fixture))
        let sut = GetDataWeatherUseCase(modelProtocol: repository, city: "Madrid,ES")

        let result = try await sut.execute()

        #expect(result.name == fixture.name)
        #expect(result.id == fixture.id)
        #expect(result.main.temp == fixture.main.temp)
    }

    @Test
    func `Execute propagates the repository error`() async {
        let repository = MockMapServicesRepository()
        let sut = GetDataWeatherUseCase(modelProtocol: repository, city: "Madrid,ES")

        await #expect(throws: MapServicesModelProtocolError.self) {
            try await sut.execute()
        }
    }
}

private final class MockMapServicesRepository: MapServicesModelProtocol, @unchecked Sendable {
    private let weatherResult: Result<MapWrapper, Error>
    private let forecastResult: Result<MapForecastWrapper, Error>
    private(set) var weatherRequestedCities: [String] = []
    private(set) var forecastRequestedCities: [String] = []

    init(
        weatherResult: Result<MapWrapper, Error> = .failure(MapServicesModelProtocolError.unaccessible),
        forecastResult: Result<MapForecastWrapper, Error> = .failure(MapServicesModelProtocolError.unaccessible)
    ) {
        self.weatherResult = weatherResult
        self.forecastResult = forecastResult
    }

    func getDataWeather(city: String) async throws -> MapWrapper {
        weatherRequestedCities.append(city)
        return try weatherResult.get()
    }

    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        forecastRequestedCities.append(city)
        return try forecastResult.get()
    }
}

private func weatherFixture() throws -> MapWrapper {
    try JSONDecoder().decode(MapWrapper.self, from: MocksManager.shared.getMockDataWeather())
}
