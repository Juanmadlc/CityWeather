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
    var errorMessage: String? { get }
}

protocol CitySelectionViewModelInput: ObservableObject {
    func onAppear() async
    func getCurrentCity() async -> String?
    func didTapContinue(city: String)
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    @Published var locationManager: LocationManager
    @Published var shouldNavigateToDashboard = false
    @Published private(set) var dashboardCity = ""
    @Published private(set) var errorMessage: String?

    private let cityStorage: CityStorageProtocol
    private let mapServicesUseCaseFactory: MapServicesUseCaseFactory
    private var hasCheckedSavedCity = false
  
    init(
        cityStorage: CityStorageProtocol = UserDefaultsCityStorage(),
        mapServicesUseCaseFactory: MapServicesUseCaseFactory = MapServicesUseCaseFactory()
    ) {
        self.cityStorage = cityStorage
        self.mapServicesUseCaseFactory = mapServicesUseCaseFactory
        locationManager = LocationManager.shared
    }
    
    // MARK: Funcs

    func onAppear() async {
        guard !hasCheckedSavedCity else { return }
        hasCheckedSavedCity = true

        guard let savedCity = cityStorage.getSelectedCity()?.trimmingCharacters(in: .whitespacesAndNewlines),
              !savedCity.isEmpty else { return }

        do {
            let useCase = mapServicesUseCaseFactory.getDataWeather(city: savedCity)
            _ = try await useCase.execute()
            dashboardCity = savedCity
            shouldNavigateToDashboard = true
        } catch {
            errorMessage = "Could not load saved city"
            Log.error("Saved city validation failed: \(error)")
        }
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
        shouldNavigateToDashboard = true
    }
}
