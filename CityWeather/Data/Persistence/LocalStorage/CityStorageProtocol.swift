//
//  CityStorageProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 16/07/2026.
//

import Foundation

protocol CityStorageProtocol {
    func saveSelectedCity(_ city: String)
    func getSelectedCity() -> String?
}
