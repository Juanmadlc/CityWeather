//
//  GeoCodingEndPoints.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

struct GeoCodingServicesEndPoints {
    static var environment: String {
        switch Bundle.main.apiEnvironment {
            case .dev: return devEnvironment
            case .pro: return proEnvironment
        }
    }
    static let devEnvironment = "geocoding-api.open-meteo.com"
    static let proEnvironment = "geocoding-api.open-meteo.com"
    
    static let dataSearch = "/v1/search"
    
    // MARK: PARAMS
    static let appid = MapServicesAPIKey.appid
    static let count = "5"
    static var language: String {
        guard let preferredLanguage = Locale.preferredLanguages.first,
              let languageCode = Locale(identifier: preferredLanguage).language.languageCode?.identifier else {
            return Constants.Locale.enLanguage
        }
        return languageCode
    }

}
