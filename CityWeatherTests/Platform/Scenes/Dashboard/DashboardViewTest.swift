//
//  DashboardViewTest.swift
//  CityWeatherTests
//
//  Created by Juan Manuel de la Cruz on 10/11/2026.
//

import Foundation
import SwiftUI
import Testing
import UIKit
@testable import CityWeather

@MainActor
@Suite
struct DashboardViewTest {

    // MARK: - DashboardView Rendering States

    @Test
    func `DashboardView renders loading state when display model is nil`() {
        let mockVM = MockDashboardViewModel()
        mockVM.hasError = false
        mockVM.weatherDisplayModel = nil

        let connector = DashboardConnector()
        let view = DashboardView(viewModel: mockVM, connector: connector, city: "Granada", country: "ES")

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.weatherDisplayModel == nil)
        #expect(mockVM.hasError == false)
    }

    @Test
    func `DashboardView renders error state when hasError is true`() {
        let mockVM = MockDashboardViewModel()
        mockVM.hasError = true
        mockVM.weatherDisplayModel = nil

        let connector = DashboardConnector()
        let view = DashboardView(viewModel: mockVM, connector: connector, city: "Granada", country: "ES")

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.hasError == true)
    }

    @Test
    func `DashboardView renders content when weatherDisplayModel is loaded from mock fixtures`() async throws {
        let displayModel = try await loadDisplayModelFromMocks()

        let mockVM = MockDashboardViewModel()
        mockVM.hasError = false
        mockVM.weatherDisplayModel = displayModel

        let connector = DashboardConnector()
        let view = DashboardView(viewModel: mockVM, connector: connector, city: "Granada", country: "ES")

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.weatherDisplayModel?.temp == "32°")
        #expect(mockVM.weatherDisplayModel?.hourlyForecast.count == 5)
        #expect(mockVM.weatherDisplayModel?.dailyForecast.count == 5)
    }

    @Test
    func `DashboardView renders progress view when display model has empty hourly forecast`() {
        let mockVM = MockDashboardViewModel()
        mockVM.hasError = false
        mockVM.weatherDisplayModel = WeatherDisplayModel(
            temp: "25°",
            description: "Soleado",
            minTemp: "18°",
            maxTemp: "28°",
            hourlyForecast: [],
            dailyForecast: []
        )

        let connector = DashboardConnector()
        let view = DashboardView(viewModel: mockVM, connector: connector, city: "Granada", country: "ES")

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.weatherDisplayModel?.hourlyForecast.isEmpty == true)
    }

    // MARK: - TemperatureView Component

    @Test
    func `TemperatureView renders correctly with data from mockWeather fixture`() async throws {
        let displayModel = try await loadDisplayModelFromMocks()
        let tempView = TemperatureView(model: displayModel)

        let controller = renderInWindow(tempView)

        #expect(controller.isViewLoaded)
        #expect(tempView.model.temp == "32°")
        #expect(tempView.model.description == "Algo De Nubes")
        #expect(tempView.model.minTemp == "32°")
        #expect(tempView.model.maxTemp == "32°")
    }

    // MARK: - TimeHoursView Component

    @Test
    func `TimeHoursView renders hourly items with divider for first item from mockForecast fixture`() async throws {
        let displayModel = try await loadDisplayModelFromMocks()
        let hoursView = TimeHoursView(hours: displayModel.hourlyForecast)

        let controller = renderInWindow(hoursView)

        #expect(controller.isViewLoaded)
        #expect(hoursView.hours.count == 5)
        #expect(hoursView.hours[0].icon == "cloud.sun.fill")
        #expect(hoursView.hours[0].color == .orange)
        #expect(hoursView.hours[1].icon == "cloud.fill")
    }

    @Test
    func `TimeHoursView handles empty hours list cleanly`() {
        let emptyHoursView = TimeHoursView(hours: [])

        let controller = renderInWindow(emptyHoursView)

        #expect(controller.isViewLoaded)
        #expect(emptyHoursView.hours.isEmpty)
    }

    // MARK: - DayForecast Component

    @Test
    func `DayForecast renders daily forecast items and header from mockForecast fixture`() async throws {
        let displayModel = try await loadDisplayModelFromMocks()
        let dayForecastView = DayForecast(forecastDays: displayModel.dailyForecast)

        let controller = renderInWindow(dayForecastView)

        #expect(controller.isViewLoaded)
        #expect(dayForecastView.forecastDays.count == 5)
        #expect(dayForecastView.forecastDays[0].temperature == "29°")
        #expect(dayForecastView.forecastDays[0].description == "Muy Nuboso")
        #expect(dayForecastView.forecastDays[0].icon == "cloud.fill")
    }

    @Test
    func `DayForecast handles empty forecast days list cleanly`() {
        let emptyDayForecast = DayForecast(forecastDays: [])

        let controller = renderInWindow(emptyDayForecast)

        #expect(controller.isViewLoaded)
        #expect(emptyDayForecast.forecastDays.isEmpty)
    }

    // MARK: - DashboardConnector

    @Test
    func `DashboardConnector assembleModule creates view with dependencies`() {
        let connector = DashboardConnector()
        let assembledView = connector.assembleModule(city: "Granada", country: "ES")

        let controller = renderInWindow(AnyView(assembledView))

        #expect(controller.isViewLoaded)
    }

    // MARK: - Previews

    @Test
    func `DashboardView previews render successfully`() {
        let preview = DashboardView_Previews.previews

        let controller = renderInWindow(AnyView(preview))

        #expect(controller.isViewLoaded)
    }

    // MARK: - ScenePhase & ViewModel Interaction

    @Test
    func `DashboardView triggers loadWeather with specified city and country`() async {
        let mockVM = MockDashboardViewModel()
        let connector = DashboardConnector()
        let view = DashboardView(viewModel: mockVM, connector: connector, city: "Granada", country: "ES")

        let controller = renderInWindow(view)

        await mockVM.loadWeather(city: "Granada", country: "ES")

        #expect(controller.isViewLoaded)
        #expect(mockVM.loadWeatherCalled == true)
        #expect(mockVM.capturedCity == "Granada")
        #expect(mockVM.capturedCountry == "ES")
    }
}

// MARK: - Test Doubles

@MainActor
private final class MockDashboardViewModel: DashboardViewModelProtocol, ObservableObject {
    @Published var hasError: Bool = false
    @Published var weatherDisplayModel: WeatherDisplayModel?

    var loadWeatherCalled = false
    var capturedCity: String?
    var capturedCountry: String?

    func loadWeather(city: String, country: String) async {
        loadWeatherCalled = true
        capturedCity = city
        capturedCountry = country
    }
}

// MARK: - Helpers

@MainActor
@discardableResult
private func renderInWindow<V: View>(_ view: V) -> UIHostingController<V> {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
    let controller = UIHostingController(rootView: view)
    window.rootViewController = controller
    window.makeKeyAndVisible()
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    _ = controller.sizeThatFits(in: CGSize(width: 393, height: 852))
    return controller
}

@MainActor
private func loadDisplayModelFromMocks() async throws -> WeatherDisplayModel {
    let apiClient = MockMapServicesAPIClient()
    let repository = MapServicesRepository(apiClient: apiClient)
    let factory = MapServicesUseCaseFactory(modelProtocol: repository)
    let vm = DashboardViewModel(mapServicesUseCaseFactory: factory)
    await vm.loadWeather(city: "Granada", country: "ES")
    return try #require(vm.weatherDisplayModel)
}
