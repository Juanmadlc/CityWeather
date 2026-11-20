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

    private let stubSuggestions: [String] = [
        "Barcelona, ES",
        "Barcelia, MX",
        "Barcelo, MX",
        "Barceló, MX",
        "Barcelona, VE"
    ]

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
    func `CitySelectionView renders with suggestions`() {
        let mockVM = MockCitySelectionViewModel()
        mockVM.isLoading = false
        mockVM.citySuggestions = stubSuggestions

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
    func `CityList renders items and invokes onSelect`() {
        var selectedCity: String?

        let cityList = CityList(cities: stubSuggestions) { selected in
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
}

// MARK: - Test Doubles

@MainActor
private final class MockCitySelectionViewModel: CitySelectionViewModelProtocol, ObservableObject {
    @Published var shouldNavigateToDashboard: Bool = false
    var dashboardCity: String = ""
    var dashboardCountry: String = ""
    @Published var isLoading: Bool = false
    @Published var citySuggestions: [String] = []
    @Published var shouldShowLocationDeniedAlert = false

    func onAppear() {}

    func getCurrentCity() async -> String? {
        "Barcelona"
    }

    func didTapContinue(city: String) {}

    func loadCitySuggestions(name: String) {}

    func resetLoading() {
        isLoading = false
    }

    func didReturnFromDashboard() {}
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
