//
//  UserDefaultsModelProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

enum UserDefaultsModelProtocolError: Error {
    case nonExistentValue
}

protocol UserDefaultsModelProtocol {
    func setUserDefaultsString(key: String, value: String)
    func getUserDefaultsString(key: String) throws -> String
}
