//
//  CityStorage.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 16/07/2026.
//

import Foundation

protocol CityStorageProtocol {
    func saveSelectedCity(_ city: String)
    func getSelectedCity() -> String?
}

final class UserDefaultsCityStorage: CityStorageProtocol {
    private enum Keys {
        static let selectedCity = "selectedCity"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSelectedCity(_ city: String) {
        userDefaults.set(city, forKey: Keys.selectedCity)
    }

    func getSelectedCity() -> String? {
        userDefaults.string(forKey: Keys.selectedCity)
    }
}
