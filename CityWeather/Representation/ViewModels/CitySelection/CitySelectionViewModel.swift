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
}

protocol CitySelectionViewModelInput: ObservableObject {
    func getCurrentCity() async -> String?
    func didTapContinue(city: String)
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    let lang: String = Constants.Locale.esLanguage // TODO: 01 Cambiar por dato persistente con el idioma escogido anteriormente y si no tiene poner por defecto idioma del iphone
    let city: String = "Barcelona" // TODO: 01 Crear una variable con dato persistente para la seleccion de la ciudad escogida y guardada anteriormente
    @Published var locationManager: LocationManager
    @Published var shouldNavigateToDashboard = false
    @Published private(set) var dashboardCity = ""
  
    init() {
        locationManager = LocationManager.shared
    }
    
    // MARK: Funcs
    
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
        dashboardCity = trimmedCity
        shouldNavigateToDashboard = true
    }
}
