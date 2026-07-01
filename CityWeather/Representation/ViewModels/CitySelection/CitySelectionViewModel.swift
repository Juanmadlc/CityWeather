//
//  CitySelectionViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 22/06/2026.
//

import Foundation

protocol CitySelectionViewModelOutput: ObservableObject {
    func getCurrentCity() -> String?
}

protocol CitySelectionViewModelInput: ObservableObject {
}

protocol CitySelectionViewModelProtocol: CitySelectionViewModelOutput, CitySelectionViewModelInput {}

class CitySelectionViewModel: CitySelectionViewModelProtocol {
    let lang: String = Constants.Locale.esLanguage // TODO: 01 Cambiar por dato persistente con el idioma escogido anteriormente y si no tiene poner por defecto idioma del iphone
    let city: String = "Barcelona" // TODO: 01 Crear una variable con dato persistente para la seleccion de la ciudad escogida y guardada anteriormente
    @Published var locationManager: LocationManager
  
    init() {
        locationManager = LocationManager.shared
    }
    
    func getCurrentCity() -> String? {
        Task { @MainActor in
            do {
                await getLocations()
                let cityCurrent = try await LocationManager.shared.currentCity()
                return cityCurrent
            } catch {
               return ""
            }
        }
        return ""
    }
    
    func getLocations() async {
        if locationManager.locationActivated {
            locationManager.requestLocation()
        }
    }
    
}
