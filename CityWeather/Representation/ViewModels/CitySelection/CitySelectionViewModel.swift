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
    var isLoading: Bool { get }
}

protocol CitySelectionViewModelInput: ObservableObject {
    func onAppear()
    func getCurrentCity() async -> String?
    func didTapContinue(city: String)
    func resetLoading()
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    @Published var locationManager: LocationManager
    @Published var shouldNavigateToDashboard = false
    @Published private(set) var dashboardCity = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let cityStorage: UserDefaultsStorageProtocol
    private var hasCheckedSavedCity = false
  
    init(
        cityStorage: UserDefaultsStorageProtocol = UserDefaultsStorage()
    ) {
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
    
    func didTapContinue(city: String) {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else { return }
        cityStorage.saveSelectedCity(trimmedCity)
        dashboardCity = trimmedCity
        isLoading = true
        shouldNavigateToDashboard = true
    }
}
