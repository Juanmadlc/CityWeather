//
//  CitySelectionViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 22/06/2026.
//

import Foundation

protocol CitySelectionViewModelOutput: ObservableObject {
    var shouldNavigateToDashboard: Bool { get set }
    var dashboardCity: String { get }
    var dashboardCountry: String { get }
    var isLoading: Bool { get }
    var cities: [String] { get }
    var citySuggestions: [String] { get }
}

protocol CitySelectionViewModelInput: ObservableObject {
    func onAppear()
    func getCurrentCity() async -> String?
    func didTapContinue(city: String)
    func loadCitySuggestions(name: String) async
    func resetLoading()
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    // MARK: - Properties
    @Published var locationManager: LocationManager
    @Published var shouldNavigateToDashboard = false
    @Published private(set) var dashboardCity = ""
    @Published private(set) var dashboardCountry = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var citySuggestions: [String] = []
    let cities = [
        "city.newYork".localized(),
        "city.london".localized(),
        "city.paris".localized(),
        "city.tokyo".localized(),
        "city.madrid".localized(),
        "city.rome".localized(),
        "city.berlin".localized(),
        "city.beijing".localized(),
        "city.sydney".localized(),
        "city.dubai".localized(),
        "city.losAngeles".localized(),
        "city.mexicoCity".localized(),
        "city.buenosAires".localized(),
        "city.toronto".localized(),
        "city.singapore".localized(),
        "city.hongKong".localized(),
        "city.seoul".localized(),
        "city.cairo".localized()
    ]

    private let cityStorage: UserDefaultsStorageProtocol
    private var hasCheckedSavedCity = false
    private var geoCodingServiceUseCaseFactory: GeoCodingServiceUseCaseFactory
    private var citySuggestionCountryCodes: [String: String] = [:]
  
    init(
        geoCodingServiceUseCaseFactory: GeoCodingServiceUseCaseFactory,
        cityStorage: UserDefaultsStorageProtocol = UserDefaultsStorage()
    ) {
        self.geoCodingServiceUseCaseFactory = geoCodingServiceUseCaseFactory
        self.cityStorage = cityStorage
        locationManager = LocationManager.shared
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
    
    func getCurrentCity() async -> String? {
        do {
            return try await getLocations()
        } catch {
            print("getCurrentCity error:", error)
            return ""
        }
    }
    
    private func getLocations() async throws -> String? {
        locationManager.requestLocation()

        return try await LocationManager.shared.currentCity()
    }
    
    @MainActor func loadCitySuggestions(name: String) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            citySuggestions = []
            return
        }
        
        do {
            let searchUseCase = geoCodingServiceUseCaseFactory.getDataSearch(name: trimmedName)
            if let wrapper = try await searchUseCase.execute() as? GeoCodingSearchWrapper {
                updateCitySuggestions(from: wrapper)
            }
        } catch {
            Log.error("Error: \(error)")
            citySuggestions = []
        }
    }

    private func updateCitySuggestions(from wrapper: GeoCodingSearchWrapper) {
        let results = wrapper.results ?? []
        let shouldShowCountryCode = results.count > 1
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
        let country: String
        if let foundCountry = citySuggestionCountryCodes[city], !foundCountry.isEmpty {
            country = foundCountry
        } else if city.contains(","), let components = city.components(separatedBy: ",").last {
            country = components.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            country = ""
        }
        
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
