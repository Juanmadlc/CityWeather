//
//  UserDefaultsStorage.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

class UserDefaultsStorage: UserDefaultsStorageProtocol {
    
    func setUserDefaultsString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func getUserDefaultsString(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
