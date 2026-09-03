//
//  UserDefaultsStorageProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 16/07/2026.
//

import Foundation

protocol UserDefaultsStorageProtocol {
    func saveSelectedCity(_ city: String)
    func saveSelectedCountry(_ country: String)
    func getSelectedCity() -> String?
    func getSelectedCountry() -> String?
}
