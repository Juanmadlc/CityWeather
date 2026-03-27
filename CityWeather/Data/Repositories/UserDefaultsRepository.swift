//
//  UserDefaultsRepository.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class UserDefaultsRepository {
    private var userDefaultsStorage: UserDefaultsStorageProtocol

    init(userDefaultsStorage: UserDefaultsStorageProtocol) {
        self.userDefaultsStorage = userDefaultsStorage
    }
}

extension UserDefaultsRepository: UserDefaultsModelProtocol {
    func setUserDefaultsString(key: String, value: String) {
        userDefaultsStorage.setUserDefaultsString(key: key, value: value)
    }

    func getUserDefaultsString(key: String) throws -> String {
        guard let result = userDefaultsStorage.getUserDefaultsString(key: key) else {
            Log.error("Key not found in user defaults: \(key)")
            throw(UserDefaultsModelProtocolError.nonExistentValue)
        }
        return result
    }
}

