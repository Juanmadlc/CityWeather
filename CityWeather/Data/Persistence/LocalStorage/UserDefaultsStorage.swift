//
//  UserDefaultsStorage.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 16/07/2026.
//

import Foundation


class UserDefaultsStorage: UserDefaultsStorageProtocol {
    private enum Keys {
        static let selectedCity = "selectedCity"
        static let selectedCountry = "selectedCountry"
    }

    func saveSelectedCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: Keys.selectedCity)
    }
    
    func saveSelectedCountry(_ country: String) {
        UserDefaults.standard.set(country, forKey: Keys.selectedCountry)
    }

    func getSelectedCity() -> String? {
        UserDefaults.standard.string(forKey: Keys.selectedCity)
    }
    
    func getSelectedCountry() -> String? {
        UserDefaults.standard.string(forKey: Keys.selectedCountry)
    }
}
