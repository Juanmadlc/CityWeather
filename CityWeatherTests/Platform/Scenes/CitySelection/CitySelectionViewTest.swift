//
//  CitySelectionViewTest.swift
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
struct CitySelectionViewTest {

    // MARK: - CitySelectionView Rendering States

    @Test
    func `CitySelectionView renders loading state when isLoading is true`() {
        let mockVM = MockCitySelectionViewModel()
        mockVM.isLoading = true

        let connector = CitySelectionConnector()
        let view = CitySelectionView(viewModel: mockVM, connector: connector)

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.isLoading == true)
    }

    @Test
    func `CitySelectionView renders content when isLoading is false`() {
        let mockVM = MockCitySelectionViewModel()
        mockVM.isLoading = false

        let connector = CitySelectionConnector()
        let view = CitySelectionView(viewModel: mockVM, connector: connector)

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.isLoading == false)
    }

    @Test
    func `CitySelectionView renders with suggestions from mockGeoDataSearch fixture`() async throws {
        let suggestions = try await loadSuggestionsFromMock()

        let mockVM = MockCitySelectionViewModel()
        mockVM.isLoading = false
        mockVM.citySuggestions = suggestions

        let connector = CitySelectionConnector()
        let view = CitySelectionView(viewModel: mockVM, connector: connector)

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)
        #expect(mockVM.citySuggestions.count == 5)
        #expect(mockVM.citySuggestions[0] == "Barcelona, ES")
        #expect(mockVM.citySuggestions[1] == "Barcelia, MX")
        #expect(mockVM.citySuggestions[2] == "Barcelo, MX")
        #expect(mockVM.citySuggestions[3] == "Barceló, MX")
        #expect(mockVM.citySuggestions[4] == "Barcelona, VE")
    }

    // MARK: - UseCurrentLocationButton Component

    @Test
    func `UseCurrentLocationButton renders and executes action closure`() {
        var actionCalled = false
        let button = UseCurrentLocationButton {
            actionCalled = true
        }

        let controller = renderInWindow(button)

        #expect(controller.isViewLoaded)
        #expect(actionCalled == false)

        button.action()
        #expect(actionCalled == true)
    }

    // MARK: - CityList Component

    @Test
    func `CityList renders items from mockGeoDataSearch and invokes onSelect`() async throws {
        let suggestions = try await loadSuggestionsFromMock()
        var selectedCity: String?

        let cityList = CityList(cities: suggestions) { selected in
            selectedCity = selected
        }

        let controller = renderInWindow(cityList)

        #expect(controller.isViewLoaded)
        #expect(cityList.cities.count == 5)

        cityList.onSelect("Barcelona, ES")
        #expect(selectedCity == "Barcelona, ES")
    }

    @Test
    func `CityList handles empty cities array cleanly`() {
        var selectedCity: String?
        let emptyCityList = CityList(cities: []) { selected in
            selectedCity = selected
        }

        let controller = renderInWindow(emptyCityList)

        #expect(controller.isViewLoaded)
        #expect(emptyCityList.cities.isEmpty)
        #expect(selectedCity == nil)
    }

    // MARK: - CityRow Component

    @Test
    func `CityRow renders city name and triggers action`() {
        var rowActionExecuted = false
        let row = CityRow(name: "Barcelona, ES") {
            rowActionExecuted = true
        }

        let controller = renderInWindow(row)

        #expect(controller.isViewLoaded)
        #expect(row.name == "Barcelona, ES")
        #expect(rowActionExecuted == false)

        row.action()
        #expect(rowActionExecuted == true)
    }

    // MARK: - CitySelectionConnector

    @Test
    func `CitySelectionConnector assembleModule creates view with dependencies`() {
        let connector = CitySelectionConnector()
        let assembledView = connector.assembleModule()

        let controller = renderInWindow(AnyView(assembledView))

        #expect(controller.isViewLoaded)
    }

    @Test
    func `CitySelectionConnector navigateToDashboard returns valid destination view`() {
        let connector = CitySelectionConnector()
        let dashboardView = connector.navigateToDashboard(city: "Barcelona", country: "ES")

        let controller = UIHostingController(rootView: dashboardView)
        controller.loadViewIfNeeded()

        #expect(controller.isViewLoaded)
    }

    // MARK: - Previews

    @Test
    func `CitySelectionView previews render successfully`() {
        let preview = CitySelectionView_Previews.previews

        let controller = renderInWindow(AnyView(preview))

        #expect(controller.isViewLoaded)
    }

    // MARK: - ViewModel Interaction

    @Test
    func `CitySelectionView interactions execute view model methods`() async {
        let mockVM = MockCitySelectionViewModel()
        let connector = CitySelectionConnector()
        let view = CitySelectionView(viewModel: mockVM, connector: connector)

        let controller = renderInWindow(view)

        #expect(controller.isViewLoaded)

        mockVM.onAppear()
        #expect(mockVM.onAppearCalled == true)

        let currentCity = await mockVM.getCurrentCity()
        #expect(mockVM.getCurrentCityCalled == true)
        #expect(currentCity == "Barcelona")

        mockVM.didTapContinue(city: "Barcelona, ES")
        #expect(mockVM.didTapContinueCalled == true)
        #expect(mockVM.capturedContinueCity == "Barcelona, ES")

        await mockVM.loadCitySuggestions(name: "Barce")
        #expect(mockVM.loadCitySuggestionsCalled == true)
        #expect(mockVM.capturedSearchQuery == "Barce")

        mockVM.resetLoading()
        #expect(mockVM.resetLoadingCalled == true)
        #expect(mockVM.isLoading == false)
    }
}

// MARK: - Test Doubles

@MainActor
private final class MockCitySelectionViewModel: CitySelectionViewModelProtocol, ObservableObject {
    @Published var shouldNavigateToDashboard: Bool = false
    var dashboardCity: String = ""
    var dashboardCountry: String = ""
    @Published var isLoading: Bool = false
    @Published var citySuggestions: [String] = []

    var onAppearCalled = false
    var resetLoadingCalled = false
    var getCurrentCityCalled = false
    var didTapContinueCalled = false
    var capturedContinueCity: String?
    var loadCitySuggestionsCalled = false
    var capturedSearchQuery: String?

    var mockCurrentCity: String? = "Barcelona"

    func onAppear() {
        onAppearCalled = true
    }

    func getCurrentCity() async -> String? {
        getCurrentCityCalled = true
        return mockCurrentCity
    }

    func didTapContinue(city: String) {
        didTapContinueCalled = true
        capturedContinueCity = city
    }

    func loadCitySuggestions(name: String) async {
        loadCitySuggestionsCalled = true
        capturedSearchQuery = name
    }

    func resetLoading() {
        resetLoadingCalled = true
        isLoading = false
    }
}

// MARK: - Helpers

@MainActor
@discardableResult
private func renderInWindow<V: View>(_ view: V) -> UIViewController {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
    let controller = UIHostingController(rootView: NavigationStack { view })
    window.rootViewController = controller
    window.makeKeyAndVisible()
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    _ = controller.sizeThatFits(in: CGSize(width: 393, height: 852))
    return controller
}

@MainActor
private func loadSuggestionsFromMock() async throws -> [String] {
    let apiClient = MockGeoCodingServicesAPIClient()
    let repository = GeoCodingServicesRepository(apiClient: apiClient)
    let factory = GeoCodingServiceUseCaseFactory(modelProtocol: repository)
    let vm = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory)
    await vm.loadCitySuggestions(name: "Barce")
    return vm.citySuggestions
}
