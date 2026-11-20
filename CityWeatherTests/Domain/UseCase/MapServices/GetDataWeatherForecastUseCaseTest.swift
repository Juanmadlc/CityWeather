//
//  GetDataWeatherForecastUseCaseTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 20/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

@Suite
struct GetDataWeatherForecastUseCaseTest {

    @Test
    func `Execute requests only the forecast for the given city`() async throws {
        let repository = MockMapServicesRepository(forecastResult: .success(try forecastFixture()))
        let sut = GetDataWeatherForecastUseCase(modelProtocol: repository, city: "Madrid,ES")

        _ = try await sut.execute()

        #expect(repository.forecastRequestedCities == ["Madrid,ES"])
        #expect(repository.weatherRequestedCities.isEmpty)
    }

    @Test
    func `Execute returns the forecast provided by the repository`() async throws {
        let fixture = try forecastFixture()
        let repository = MockMapServicesRepository(forecastResult: .success(fixture))
        let sut = GetDataWeatherForecastUseCase(modelProtocol: repository, city: "Madrid,ES")

        let result = try await sut.execute() as? MapForecastWrapper

        #expect(result?.city.name == fixture.city.name)
        #expect(result?.list.count == fixture.list.count)
    }

    @Test
    func `Execute propagates the repository error`() async {
        let repository = MockMapServicesRepository()
        let sut = GetDataWeatherForecastUseCase(modelProtocol: repository, city: "Madrid,ES")

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

private func forecastFixture() throws -> MapForecastWrapper {
    try JSONDecoder().decode(MapForecastWrapper.self, from: MocksManager.shared.getMockDataForecast())
}
