//
//  UserDefaultsStorageProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

protocol UserDefaultsStorageProtocol {
    func setUserDefaultsString(key: String, value: String)
    func getUserDefaultsString(key: String) -> String?
}
