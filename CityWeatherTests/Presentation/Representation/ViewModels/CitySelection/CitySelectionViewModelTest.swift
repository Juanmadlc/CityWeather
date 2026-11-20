//
//  CitySelectionViewModelTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

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

    @Test
    func `didReturnFromDashboard removes the saved city`() {
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: MockGeoCodingServicesModel())
        let storage = MockUserDefaultsStorage()
        storage.savedCity = "Bilbao"
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.didReturnFromDashboard()

        #expect(storage.removeSelectedCityCountryCalled == true)
    }

    // MARK: - loadCitySuggestions with mockGeoDataSearch

    @Test
    func `loadCitySuggestions with empty or whitespace name clears suggestions`() async {
        let mockModel = MockGeoCodingServicesModel()
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.loadCitySuggestions(name: "")
        await sut.searchTask?.value
        #expect(sut.citySuggestions.isEmpty)

        sut.loadCitySuggestions(name: "   \n\t  ")
        await sut.searchTask?.value
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

        sut.loadCitySuggestions(name: "  Barcelona  ")
        await sut.searchTask?.value

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

    @Test(arguments: ["Barcelona, ES", "  barcelona ,  es  "])
    func `loadCitySuggestions with country code searches by city and keeps only that country`(query: String) async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try loadMockGeoSearch())
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let sut = CitySelectionViewModel(
            geoCodingServiceUseCaseFactory: factory,
            cityStorage: MockUserDefaultsStorage(),
            searchDebounce: .zero
        )

        sut.loadCitySuggestions(name: query)
        await sut.searchTask?.value

        #expect(mockModel.capturedSearchName?.lowercased() == "barcelona")
        #expect(sut.citySuggestions == ["Barcelona, ES"])
    }

    @Test
    func `Selecting a suggestion filtered by country navigates with that country`() async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try loadMockGeoSearch())
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(
            geoCodingServiceUseCaseFactory: factory,
            cityStorage: storage,
            searchDebounce: .zero
        )

        sut.loadCitySuggestions(name: "Barcelona, ES")
        await sut.searchTask?.value
        sut.didTapContinue(city: "Barcelona, ES")

        #expect(sut.dashboardCity == "Barcelona")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.shouldNavigateToDashboard == true)
    }

    @Test
    func `loadCitySuggestions sets empty suggestions when search service throws`() async {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .failure(GeoCodingServicesModelProtocolError.unaccessible)
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.loadCitySuggestions(name: "Granada")
        await sut.searchTask?.value

        #expect(sut.citySuggestions.isEmpty)
    }

    @Test
    func `loadCitySuggestions handles non-GeoCodingSearchWrapper use case result`() async {
        let mockModel = MockGeoCodingServicesModel()
        let factory = NonGeoCodingWrapperFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.loadCitySuggestions(name: "Madrid")
        await sut.searchTask?.value

        #expect(sut.citySuggestions.isEmpty)
    }

    @Test
    func `New search cancels the previous one and stale results are never shown`() async throws {
        let model = GatedGeoCodingServicesModel(
            gatedName: "Mad",
            results: ["Mad": try searchWrapper(names: ["Madeira"]), "Madrid": try searchWrapper(names: ["Madrid"])]
        )
        let sut = makeSearchSUT(model: model)

        sut.loadCitySuggestions(name: "Mad")
        let staleTask = sut.searchTask
        await model.probe.waitUntilGateEntered()

        sut.loadCitySuggestions(name: "Madrid")
        await sut.searchTask?.value
        #expect(sut.citySuggestions == ["Madrid"])

        await model.probe.openGate()
        await staleTask?.value
        #expect(sut.citySuggestions == ["Madrid"])
    }

    @Test
    func `Empty search text cancels the in-flight search and clears suggestions`() async throws {
        let model = GatedGeoCodingServicesModel(gatedName: "Mad", results: ["Mad": try searchWrapper(names: ["Madeira"])])
        let sut = makeSearchSUT(model: model)

        sut.loadCitySuggestions(name: "Mad")
        let staleTask = sut.searchTask
        await model.probe.waitUntilGateEntered()

        sut.loadCitySuggestions(name: "   ")
        #expect(sut.citySuggestions.isEmpty)

        await model.probe.openGate()
        await staleTask?.value
        #expect(sut.citySuggestions.isEmpty)
    }

    @Test
    func `Debounce only sends the last query typed in quick succession`() async throws {
        let model = GatedGeoCodingServicesModel(gatedName: nil, results: ["Madrid": try searchWrapper(names: ["Madrid"])])
        let sut = makeSearchSUT(model: model, debounce: .milliseconds(100))

        sut.loadCitySuggestions(name: "Ma")
        sut.loadCitySuggestions(name: "Madrid")
        await sut.searchTask?.value

        #expect(await model.probe.requestedNames == ["Madrid"])
        #expect(sut.citySuggestions == ["Madrid"])
    }

    @Test
    func `Cancellation errors keep current suggestions and are not treated as failures`() async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try searchWrapper(names: ["Madrid"]))
        let sut = makeSearchSUT(model: mockModel)
        sut.loadCitySuggestions(name: "Madrid")
        await sut.searchTask?.value

        mockModel.searchResult = .failure(CancellationError())
        sut.loadCitySuggestions(name: "Mad")
        await sut.searchTask?.value
        #expect(sut.citySuggestions == ["Madrid"])

        mockModel.searchResult = .failure(URLError(.cancelled))
        sut.loadCitySuggestions(name: "Mad")
        await sut.searchTask?.value
        #expect(sut.citySuggestions == ["Madrid"])
    }

    // MARK: - didTapContinue

    @Test
    func `didTapContinue with suggestion containing stored country code`() async throws {
        let mockModel = MockGeoCodingServicesModel()
        mockModel.searchResult = .success(try loadMockGeoSearch())
        let factory = GeoCodingServiceUseCaseFactory(modelProtocol: mockModel)
        let storage = MockUserDefaultsStorage()
        let sut = CitySelectionViewModel(geoCodingServiceUseCaseFactory: factory, cityStorage: storage)

        sut.loadCitySuggestions(name: "Barcelona")
        await sut.searchTask?.value

        sut.didTapContinue(city: "Barcelona, ES")

        #expect(sut.dashboardCity == "Barcelona")
        #expect(sut.dashboardCountry == "ES")
        #expect(sut.isLoading == true)
        #expect(sut.shouldNavigateToDashboard == true)

        #expect(storage.savedCity == "Barcelona")
        #expect(storage.savedCountry == "ES")
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

    private(set) var removeSelectedCityCountryCalled = false

    func removeSelectedCityCountry() {
        removeSelectedCityCountryCalled = true
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

private actor SearchProbe {
    private(set) var requestedNames: [String] = []
    private var isGateOpen = false
    private var hasEnteredGate = false
    private var gateContinuation: CheckedContinuation<Void, Never>?
    private var enteredContinuation: CheckedContinuation<Void, Never>?

    func record(_ name: String) {
        requestedNames.append(name)
    }

    func waitAtGate() async {
        hasEnteredGate = true
        enteredContinuation.take()?.resume()
        guard !isGateOpen else { return }
        await withCheckedContinuation { gateContinuation = $0 }
    }

    func waitUntilGateEntered() async {
        guard !hasEnteredGate else { return }
        await withCheckedContinuation { enteredContinuation = $0 }
    }

    func openGate() {
        isGateOpen = true
        gateContinuation.take()?.resume()
    }
}

private final class GatedGeoCodingServicesModel: GeoCodingServicesModelProtocol, Sendable {
    let probe = SearchProbe()
    private let gatedName: String?
    private let results: [String: GeoCodingSearchWrapper]

    init(gatedName: String?, results: [String: GeoCodingSearchWrapper]) {
        self.gatedName = gatedName
        self.results = results
    }

    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        await probe.record(name)
        if name == gatedName {
            await probe.waitAtGate()
        }
        guard let result = results[name] else {
            throw GeoCodingServicesModelProtocolError.unaccessible
        }
        return result
    }
}

@MainActor
private func makeSearchSUT(
    model: GeoCodingServicesModelProtocol,
    debounce: Duration = .zero
) -> CitySelectionViewModel {
    CitySelectionViewModel(
        geoCodingServiceUseCaseFactory: GeoCodingServiceUseCaseFactory(modelProtocol: model),
        cityStorage: MockUserDefaultsStorage(),
        searchDebounce: debounce
    )
}

// MARK: - Mocks Loading Helpers

private func searchWrapper(names: [String]) throws -> GeoCodingSearchWrapper {
    let json: [String: Any] = ["results": names.map { ["name": $0] }]
    let data = try JSONSerialization.data(withJSONObject: json)
    return try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: data)
}

private func loadMockGeoSearch() throws -> GeoCodingSearchWrapper {
    let data = try MocksManager.shared.getMockGeoDataSearch()
    return try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: data)
}
