//
//  CitySelectionViewModelTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import CoreLocation
import Foundation
import Testing
@testable import CityWeather

@MainActor
@Suite
struct CitySelectionViewModelTest {

    // MARK: - Initial State & Protocol

    @Test
    func `Initial state has default values`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.dashboardCity == "")
        #expect(sut.dashboardCountry == "")
        #expect(sut.isLoading == false)
        #expect(sut.citySuggestions.isEmpty)
    }

    @Test
    func `Conforms to CitySelectionViewModelProtocol`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut: any CitySelectionViewModelProtocol = CitySelectionViewModel(
            geoCodingServiceUseCaseFactory: factory,
            cityStorage: storage
        )

        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.dashboardCity == "")
        #expect(sut.dashboardCountry == "")
        #expect(sut.isLoading == false)
        #expect(sut.citySuggestions.isEmpty)
    }

    // MARK: - onAppear

    @Test
    func `onAppear navigates to dashboard when city is saved in storage`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        storage.savedCity = "Madrid"
        storage.savedCountry = "ES"

        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)
        sut.onAppear()

        #expect(sut.dashboardCity == "Madrid")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)
    }

    @Test
    func `onAppear handles saved city without saved country`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        storage.savedCity = "Barcelona"
        storage.savedCountry = nil

        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)
        sut.onAppear()

        #expect(sut.dashboardCity == "Barcelona")
        #expect(sut.dashboardCountry == "")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)
    }

    @Test
    func `onAppear trims whitespace in saved city and country`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        storage.savedCity = "   Sevilla   "
        storage.savedCountry = "   ES   "

        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)
        sut.onAppear()

        #expect(sut.dashboardCity == "Sevilla")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.shouldNavigateToDashboard == true)
    }

    @Test
    func `onAppear does not navigate when saved city is nil empty or only whitespace`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)

        // Case 1: nil
        let storageNil = MockUserDefaultsStorage()
        let sut1 = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storageNil)
        sut1.onAppear()
        #expect(sut1.shouldNavigateToDashboard == false)
        #expect(sut1.isLoading == false)

        // Case 2: empty
        let storageEmpty = MockUserDefaultsStorage()
        storageEmpty.savedCity = ""
        let sut2 = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storageEmpty)
        sut2.onAppear()
        #expect(sut2.shouldNavigateToDashboard == false)
        #expect(sut2.isLoading == false)

        // Case 3: whitespace only
        let storageWhitespace = MockUserDefaultsStorage()
        storageWhitespace.savedCity = "   \n\t   "
        let sut3 = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storageWhitespace)
        sut3.onAppear()
        #expect(sut3.shouldNavigateToDashboard == false)
        #expect(sut3.isLoading == false)
    }

    @Test
    func `onAppear is idempotent and only checks saved city once`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        storage.savedCity = nil

        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)
        sut.onAppear()
        #expect(sut.shouldNavigateToDashboard == false)

        // Modifying storage afterwards should not trigger navigation on subsequent onAppear calls
        storage.savedCity = "Valencia"
        sut.onAppear()
        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.dashboardCity == "")
    }

    // MARK: - resetLoading

    @Test
    func `resetLoading sets isLoading to false`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        storage.savedCity = "Bilbao"

        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)
        sut.onAppear()
        #expect(sut.isLoading == true)

        sut.resetLoading()
        #expect(sut.isLoading == false)
    }

    // MARK: - loadCitySuggestions with mockGeoDataSearch

    @Test
    func `loadCitySuggestions with empty or whitespace name clears suggestions`() async {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "")
        #expect(sut.citySuggestions.isEmpty)

        await sut.loadCitySuggestions(name: "   \n\t  ")
        #expect(sut.citySuggestions.isEmpty)
        #expect(mockModel.capturedSearchName == nil)
    }

    @Test
    func `loadCitySuggestions populates suggestions and country codes from mockGeoDataSearch fixture`() async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try loadMockGeoSearch())
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "  Barcelona  ")

        #expect(mockModel.capturedSearchName == "Barcelona")
        #expect(sut.citySuggestions.count == 5)
        #expect(sut.citySuggestions == [
            "Barcelona, ES",
            "Barcelia, MX",
            "Barcelo, MX",
            "Barceló, MX",
            "Barcelona, VE"
        ])
    }

    @Test
    func `loadCitySuggestions sets empty suggestions when search service throws`() async {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .failure(GeoCodingServicesModelProtocolError.unaccessible)
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "Granada")

        #expect(sut.citySuggestions.isEmpty)
    }

    @Test
    func `loadCitySuggestions handles non-GeoCodingSearchWrapper use case result`() async {
        let mockModel = MockGeoCodingServicesModel()
        let factory = NonGeoCodingWrapperFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "Madrid")

        #expect(sut.citySuggestions.isEmpty)
    }

    // MARK: - didTapContinue

    @Test
    func `didTapContinue with suggestion containing stored country code`() async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try loadMockGeoSearch())
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "Barcelona")

        sut.didTapContinue(city: "Barcelona, ES")

        #expect(sut.dashboardCity == "Barcelona")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)

        #expect(storage.savedCity == "Barcelona")
        #expect(storage.savedCountry == "ES")
    }

    @Test
    func `didTapContinue with comma-separated city and country not in suggestions map`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.didTapContinue(city: "Paris, FR")

        #expect(sut.dashboardCity == "Paris")
        #expect(sut.dashboardCountry == "FR")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)

        #expect(storage.savedCity == "Paris")
        #expect(storage.savedCountry == "FR")
    }

    @Test
    func `didTapContinue with single city name without country`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.didTapContinue(city: "Berlin")

        #expect(sut.dashboardCity == "Berlin")
        #expect(sut.dashboardCountry == "")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)

        #expect(storage.savedCity == "Berlin")
        #expect(storage.savedCountry == "")
    }

    @Test
    func `didTapContinue with empty city does not navigate or save`() {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.didTapContinue(city: "")
        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.isLoading == false)
        #expect(storage.savedCity == nil)

        sut.didTapContinue(city: "   \n\t  ")
        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.isLoading == false)
        #expect(storage.savedCity == nil)

        sut.didTapContinue(city: "   , FR")
        #expect(sut.shouldNavigateToDashboard == false)
        #expect(sut.isLoading == false)
        #expect(storage.savedCity == nil)
    }

    // MARK: - End to End Integration with MockGeoCodingServicesAPIClient

    @Test
    func `loadCitySuggestions and didTapContinue succeed end-to-end with MockGeoCodingServicesAPIClient`() async {
        let mockAPIClient = MockGeoCodingServicesAPIClient()
        let repository = GeoCodingServicesRepository(apiClient: mockAPIClient)
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: repository)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        await sut.loadCitySuggestions(name: "Barc")

        #expect(sut.citySuggestions.count == 5)
        #expect(sut.citySuggestions.contains("Barcelona, ES"))

        sut.didTapContinue(city: "Barcelona, ES")

        #expect(sut.dashboardCity == "Barcelona")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)
        #expect(storage.savedCity == "Barcelona")
        #expect(storage.savedCountry == "ES")
    }

    // MARK: - getCurrentCity

    @Test
    func `getCurrentCity handles execution safely without throwing`() async {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        LocationManager.shared.userLocation = CLLocation(latitude: 40.4168, longitude: -3.7038)

        let result = await sut.getCurrentCity()
        #expect(result != nil)
    }
}

// MARK: - Test Doubles

private final class MockUserDefaultsStorage: UserDefaultsStorageProtocol, @unchecked Sendable {
    var savedCity: String?
    var savedCountry: String?

    func saveSelectedCity(_ city: String) {
        savedCity = city
    }

    func saveSelectedCountry(_ country: String) {
        savedCountry = country
    }

    func getSelectedCity() -> String? {
        savedCity
    }

    func getSelectedCountry() -> String? {
        savedCountry
    }
}

private final class MockGeoCodingServicesModel: GeoCodingServicesModelProtocol, @unchecked Sendable {
    var searchResult: Result<GeoCodingSearchWrapper, Error>?
    var capturedSearchName: String?

    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        capturedSearchName = name
        guard let searchResult else {
            throw GeoCodingServicesModelProtocolError.unaccessible
        }
        return try searchResult.get()
    }
}

private struct DummyNonGeoCodingWrapperUseCase: AsyncUseCase, Sendable {
    func execute() async throws -> String {
        return "not a geocoding search wrapper"
    }
}

private final class NonGeoCodingWrapperFactory: GeoCodingServiceUseCaseFactory, @unchecked Sendable {
    override func getDataSearch(name: String) -> any AsyncUseCase {
        DummyNonGeoCodingWrapperUseCase()
    }
}

// MARK: - Mocks Loading Helpers

private func loadMockGeoSearch() throws -> GeoCodingSearchWrapper {
    let data = try MocksManager.shared.getMockGeoDataSearch()
    return try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: data)
}
