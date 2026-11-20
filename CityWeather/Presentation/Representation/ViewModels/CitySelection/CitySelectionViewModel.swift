//
//  CitySelectionViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 22/06/2026.
//

import Foundation

@MainActor
protocol CitySelectionViewModelOutput: ObservableObject {
    var shouldNavigateToDashboard: Bool { get set }
    var dashboardCity: String { get }
    var dashboardCountry: String { get }
    var isLoading: Bool { get }
    var citySuggestions: [String] { get }
    var shouldShowLocationDeniedAlert: Bool { get set }
}

@MainActor
protocol CitySelectionViewModelInput: ObservableObject {
    func onAppear()
    func getCurrentCity() async -> String?
    func didTapContinue(city: String)
    func loadCitySuggestions(name: String)
    func resetLoading()
    func didReturnFromDashboard()
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    // MARK: - Properties
    @Published var shouldNavigateToDashboard = false
    @Published private(set) var dashboardCity = ""
    @Published private(set) var dashboardCountry = ""
    @Published private(set) var isLoading = false
    @Published private(set) var citySuggestions: [String] = []
    @Published var shouldShowLocationDeniedAlert = false
    private let locationManager: LocationManager
    private let cityStorage: UserDefaultsStorageProtocol
    private var hasCheckedSavedCity = false
    private let geoCodingServiceUseCaseFactory: GeoCodingServiceUseCaseFactory
    private var citySuggestionCountryCodes: [String: String] = [:]
    private(set) var searchTask: Task<Void, Never>?
    private let searchDebounce: Duration

    init(
        geoCodingServiceUseCaseFactory: GeoCodingServiceUseCaseFactory,
        cityStorage: UserDefaultsStorageProtocol = UserDefaultsStorage(),
        searchDebounce: Duration = Constants.Search.debounce
    ) {
        self.geoCodingServiceUseCaseFactory = geoCodingServiceUseCaseFactory
        self.cityStorage = cityStorage
        self.searchDebounce = searchDebounce
        self.locationManager = .shared
    }
    
    // MARK: Funcs

    func onAppear() {
        guard !hasCheckedSavedCity else { return }
        hasCheckedSavedCity = true
        
        guard let savedCity = cityStorage.getSelectedCity()?.trimmingCharacters(in: .whitespacesAndNewlines),
              !savedCity.isEmpty else { return }
        
        dashboardCity = savedCity
        dashboardCountry = cityStorage.getSelectedCountry()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        isLoading = true
        shouldNavigateToDashboard = true
    }
    
    func resetLoading() {
        isLoading = false
    }

    func didReturnFromDashboard() {
        cityStorage.removeSelectedCityCountry()
    }

    func getCurrentCity() async -> String? {
        guard !locationManager.isAuthorizationDenied else {
            shouldShowLocationDeniedAlert = true
            return ""
        }
        do {
            return try await getLocations()
        } catch {
            Log.error("Error: \(error)")
            return ""
        }
    }
    
    private func getLocations() async throws -> String? {
        locationManager.requestLocation()
        return try await locationManager.currentCity()
    }
    
    func loadCitySuggestions(name: String) {
        searchTask?.cancel()

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            citySuggestions = []
            return
        }

        searchTask = Task { [weak self, searchDebounce] in
            try? await Task.sleep(for: searchDebounce)
            guard !Task.isCancelled else { return }
            await self?.fetchCitySuggestions(name: trimmedName)
        }
    }

    private func fetchCitySuggestions(name trimmedName: String) async {
        let searchTerms = searchTerms(from: trimmedName)
        do {
            let searchUseCase = geoCodingServiceUseCaseFactory.getDataSearch(name: searchTerms.city)
            if let wrapper = try await searchUseCase.execute() as? GeoCodingSearchWrapper, !Task.isCancelled {
                updateCitySuggestions(from: wrapper, countryCode: searchTerms.countryCode)
            }
        } catch {
            guard !isCancellation(error) else { return }
            Log.error("Error: \(error)")
            citySuggestions = []
        }
    }

    private func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }

    private func searchTerms(from query: String) -> (city: String, countryCode: String) {
        let parts = query
            .split(separator: ",", maxSplits: 1)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let city = parts.first ?? query
        let countryCode = parts.count > 1 ? parts[1].uppercased() : ""
        return (city, countryCode)
    }

    private func updateCitySuggestions(from wrapper: GeoCodingSearchWrapper, countryCode filterCountryCode: String) {
        let allResults = wrapper.results ?? []
        let results = filterCountryCode.isEmpty
            ? allResults
            : allResults.filter { $0.countryCode?.uppercased() == filterCountryCode }
        let shouldShowCountryCode = results.count > 1 || !filterCountryCode.isEmpty
        var seenCities = Set<String>()
        var suggestions: [String] = []
        var countryCodes: [String: String] = [:]
        
        for result in results {
            guard let name = result.name, !name.isEmpty else { continue }
            
            let city: String
            if shouldShowCountryCode,
               let country = result.countryCode,
               !country.isEmpty {
                city = "\(name), \(country)"
            } else {
                city = name
            }
            
            guard !seenCities.contains(city) else { continue }
            seenCities.insert(city)
            suggestions.append(city)
            
            if let countryCode = result.countryCode, !countryCode.isEmpty {
                countryCodes[city] = countryCode
            }
        }
        
        citySuggestionCountryCodes = countryCodes
        citySuggestions = suggestions
    }
    
    func didTapContinue(city: String) {
        let country = citySuggestionCountryCodes[city] ?? ""

        let trimmedCity = city
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !trimmedCity.isEmpty else { return }
        
        cityStorage.saveSelectedCity(trimmedCity)
        cityStorage.saveSelectedCountry(country)
        dashboardCity = trimmedCity
        dashboardCountry = country
        isLoading = true
        shouldNavigateToDashboard = true
    }
}
