//
//  DashboardViewModelTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import Foundation
import SwiftUI
import Testing
@testable import CityWeather

@MainActor
@Suite
struct DashboardViewModelTest {

    // MARK: - Initial State & Protocol

    @Test
    func `Initial state has nil weather display model and false error flag`() {
        let mockModel = MockMapServicesModel()
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        #expect(sut.weatherDisplayModel == nil)
        #expect(sut.hasError == false)
    }

    @Test
    func `Conforms to DashboardViewModelProtocol`() {
        let mockModel = MockMapServicesModel()
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut: any DashboardViewModelProtocol = DashboardViewModel(mapServicesUseCaseFactory: factory)

        #expect(sut.weatherDisplayModel == nil)
        #expect(sut.hasError == false)
    }

    // MARK: - Query Formatting

    @Test
    func `loadWeather formats query with city and country`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(mockModel.capturedWeatherCity == "Granada,ES")
        #expect(mockModel.capturedForecastCity == "Granada,ES")
    }

    @Test
    func `loadWeather trims whitespace in city and country`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "  Granada  ", country: "  ES  ")

        #expect(mockModel.capturedWeatherCity == "Granada,ES")
        #expect(mockModel.capturedForecastCity == "Granada,ES")
    }

    @Test
    func `loadWeather formats query with only city when country is empty or whitespace`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "")
        #expect(mockModel.capturedWeatherCity == "Granada")

        await sut.loadWeather(city: "Granada", country: "   \n\t  ")
        #expect(mockModel.capturedWeatherCity == "Granada")
    }

    // MARK: - Display Model from mockWeather

    @Test
    func `loadWeather updates display model with data from mockWeather fixture`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(sut.hasError == false)
        let displayModel = try #require(sut.weatherDisplayModel)
        #expect(displayModel.temp == "32°")
        #expect(displayModel.minTemp == "32°")
        #expect(displayModel.maxTemp == "32°")
        #expect(displayModel.description == "Algo De Nubes")
    }

    // MARK: - Hourly Forecast from mockForecast

    @Test
    func `loadWeather limits hourly forecast to maximum of 5 items from mockForecast fixture`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        let displayModel = try #require(sut.weatherDisplayModel)
        #expect(displayModel.hourlyForecast.count == 5)

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h a"

        let expectedFirstDate = parser.date(from: "2026-09-07 18:00:00")!
        let expectedFirstTime = displayFormatter.string(from: expectedFirstDate)

        #expect(displayModel.hourlyForecast[0].time == expectedFirstTime)
        #expect(displayModel.hourlyForecast[0].icon == "cloud.sun.fill")
        #expect(displayModel.hourlyForecast[0].color == .orange)

        #expect(displayModel.hourlyForecast[1].icon == "cloud.fill")
        #expect(displayModel.hourlyForecast[1].color == .gray)

        #expect(displayModel.hourlyForecast[2].icon == "cloud.moon.fill")
        #expect(displayModel.hourlyForecast[2].color == .indigo)

        #expect(displayModel.hourlyForecast[3].icon == "cloud.fill")
        #expect(displayModel.hourlyForecast[3].color == .gray)

        #expect(displayModel.hourlyForecast[4].icon == "cloud.sun.fill")
        #expect(displayModel.hourlyForecast[4].color == .orange)
    }

    // MARK: - Daily Forecast from mockForecast

    @Test
    func `loadWeather filters daily forecast by 12:00:00 and limits to 5 items from mockForecast fixture`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        let displayModel = try #require(sut.weatherDisplayModel)
        #expect(displayModel.dailyForecast.count == 5)

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"

       
        let date1 = parser.date(from: "2026-09-08 12:00:00")!
        #expect(displayModel.dailyForecast[0].day == dayFormatter.string(from: date1).capitalized)
        #expect(displayModel.dailyForecast[0].temperature == "29°")
        #expect(displayModel.dailyForecast[0].description == "Muy Nuboso")
        #expect(displayModel.dailyForecast[0].icon == "cloud.fill")
        #expect(displayModel.dailyForecast[0].color == .gray)


        let date2 = parser.date(from: "2026-09-09 12:00:00")!
        #expect(displayModel.dailyForecast[1].day == dayFormatter.string(from: date2).capitalized)
        #expect(displayModel.dailyForecast[1].temperature == "27°")
        #expect(displayModel.dailyForecast[1].description == "Nubes")
        #expect(displayModel.dailyForecast[1].icon == "cloud.fill")
        #expect(displayModel.dailyForecast[1].color == .gray)

        let date3 = parser.date(from: "2026-09-10 12:00:00")!
        #expect(displayModel.dailyForecast[2].day == dayFormatter.string(from: date3).capitalized)
        #expect(displayModel.dailyForecast[2].temperature == "24°")
        #expect(displayModel.dailyForecast[2].description == "Muy Nuboso")
        #expect(displayModel.dailyForecast[2].icon == "cloud.fill")
        #expect(displayModel.dailyForecast[2].color == .gray)

        let date4 = parser.date(from: "2026-09-11 12:00:00")!
        #expect(displayModel.dailyForecast[3].day == dayFormatter.string(from: date4).capitalized)
        #expect(displayModel.dailyForecast[3].temperature == "26°")
        #expect(displayModel.dailyForecast[3].description == "Cielo Claro")
        #expect(displayModel.dailyForecast[3].icon == "sun.max.fill")
        #expect(displayModel.dailyForecast[3].color == .yellow)

        let date5 = parser.date(from: "2026-09-12 12:00:00")!
        #expect(displayModel.dailyForecast[4].day == dayFormatter.string(from: date5).capitalized)
        #expect(displayModel.dailyForecast[4].temperature == "28°")
        #expect(displayModel.dailyForecast[4].description == "Cielo Claro")
        #expect(displayModel.dailyForecast[4].icon == "sun.max.fill")
        #expect(displayModel.dailyForecast[4].color == .yellow)
    }

    // MARK: - Error Handling

    @Test
    func `loadWeather sets hasError when weather service throws`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .failure(MapServicesModelProtocolError.unaccessible)
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(sut.hasError == true)
        #expect(sut.weatherDisplayModel == nil)
    }

    @Test
    func `loadWeather sets hasError when forecast service throws`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .failure(MapServicesModelProtocolError.unaccessible)
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(sut.hasError == true)
    }

    @Test
    func `loadWeather resets hasError to false at start of new load`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.weatherResult = .failure(MapServicesModelProtocolError.unaccessible)
        let factory = MapServicesUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")
        #expect(sut.hasError == true)

        mockModel.weatherResult = .success(try loadMockWeather())
        mockModel.forecastResult = .success(try loadMockForecast())
        await sut.loadWeather(city: "Granada", country: "ES")
        #expect(sut.hasError == false)
    }

    // MARK: - Guard on weatherDisplayModel

    @Test
    func `updateForecastDisplayModel returns early if weatherDisplayModel is nil`() async throws {
        let mockModel = MockMapServicesModel()
        mockModel.forecastResult = .success(try loadMockForecast())
        let factory = NonWeatherUseCaseFactory(modelProtocol: mockModel)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(sut.weatherDisplayModel == nil)
        #expect(sut.hasError == false)
    }

    // MARK: - End to End Integration with MockMapServicesAPIClient

    @Test
    func `loadWeather succeeds end-to-end with MockMapServicesAPIClient`() async throws {
        let mockAPIClient = MockMapServicesAPIClient()
        let repository = MapServicesRepository(apiClient: mockAPIClient)
        let factory = MapServicesUseCaseFactory(modelProtocol: repository)
        let sut = DashboardViewModel(mapServicesUseCaseFactory: factory)

        await sut.loadWeather(city: "Granada", country: "ES")

        #expect(sut.hasError == false)
        let displayModel = try #require(sut.weatherDisplayModel)
        #expect(displayModel.temp == "32°")
        #expect(displayModel.minTemp == "32°")
        #expect(displayModel.maxTemp == "32°")
        #expect(displayModel.description == "Algo De Nubes")
        #expect(displayModel.hourlyForecast.count == 5)
        #expect(displayModel.dailyForecast.count == 5)
    }

    // MARK: - Display Models Initializers

    @Test
    func `WeatherDisplayModel initializes correctly with default and custom values`() {
        let hourly = [HourlyForecastModel(time: "12 PM", icon: "sun.max.fill", color: .yellow)]
        let daily = [DailyForecastModel(day: "Lunes", temperature: "25°", description: "Soleado", icon: "sun.max.fill", color: .yellow)]

        let model = WeatherDisplayModel(
            temp: "25°",
            description: "Soleado",
            minTemp: "18°",
            maxTemp: "28°",
            hourlyForecast: hourly,
            dailyForecast: daily
        )

        #expect(model.temp == "25°")
        #expect(model.description == "Soleado")
        #expect(model.minTemp == "18°")
        #expect(model.maxTemp == "28°")
        #expect(model.hourlyForecast.count == 1)
        #expect(model.dailyForecast.count == 1)

        let modelWithDefaultDaily = WeatherDisplayModel(
            temp: "20°",
            description: "Nublado",
            minTemp: "15°",
            maxTemp: "22°",
            hourlyForecast: []
        )
        #expect(modelWithDefaultDaily.dailyForecast.isEmpty)
    }

    @Test
    func `DailyForecastModel and HourlyForecastModel initialize properties correctly`() {
        let daily = DailyForecastModel(day: "Martes", temperature: "22°", description: "Lluvia", icon: "cloud.rain.fill", color: .blue)
        #expect(daily.day == "Martes")
        #expect(daily.temperature == "22°")
        #expect(daily.description == "Lluvia")
        #expect(daily.icon == "cloud.rain.fill")
        #expect(daily.color == .blue)

        let hourly = HourlyForecastModel(time: "3 PM", icon: "cloud.fill", color: .gray)
        #expect(hourly.time == "3 PM")
        #expect(hourly.icon == "cloud.fill")
        #expect(hourly.color == .gray)
    }
}

// MARK: - Test Doubles

private final class MockMapServicesModel: MapServicesModelProtocol, @unchecked Sendable {
    var weatherResult: Result<MapWrapper, Error>?
    var forecastResult: Result<MapForecastWrapper, Error>?

    var capturedWeatherCity: String?
    var capturedForecastCity: String?

    func getDataWeather(city: String) async throws -> MapWrapper {
        capturedWeatherCity = city
        guard let weatherResult else {
            throw MapServicesModelProtocolError.unaccessible
        }
        return try weatherResult.get()
    }

    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        capturedForecastCity = city
        guard let forecastResult else {
            throw MapServicesModelProtocolError.unaccessible
        }
        return try forecastResult.get()
    }
}

private struct DummyNonWrapperUseCase: AsyncUseCase, Sendable {
    func execute() async throws -> String {
        return "not a map wrapper"
    }
}

private final class NonWeatherUseCaseFactory: MapServicesUseCaseFactory, @unchecked Sendable {
    override func getDataWeather(city: String) -> any AsyncUseCase {
        DummyNonWrapperUseCase()
    }
}

// MARK: - Mocks Loading Helpers

private func loadMockWeather() throws -> MapWrapper {
    let data = try MocksManager.shared.getMockDataWeather()
    return try JSONDecoder().decode(MapWrapper.self, from: data)
}

private func loadMockForecast() throws -> MapForecastWrapper {
    let data = try MocksManager.shared.getMockDataForecast()
    return try JSONDecoder().decode(MapForecastWrapper.self, from: data)
}
