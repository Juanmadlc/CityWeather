//
//  MapServicesEndpoints.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

struct MapServicesEndpoints {
    static var environment: String {
        switch Bundle.main.apiEnvironment {
            case .dev: return devEnvironment
            case .pro: return proEnvironment
        }
    }
    static let devEnvironment = "api.openweathermap.org"
    static let proEnvironment = "api.openweathermap.org"
    
    static let dataWeather = "/data/2.5/weather"
    static let dataForecast = "/data/2.5/forecast"
    
    // MARK: PARAMS
    static let appid = "768543f20334a8c0ab4d96b800f607e5"
    static let units = "metric"
    static var language: String {
        guard let preferredLanguage = Locale.preferredLanguages.first,
              let languageCode = Locale(identifier: preferredLanguage).language.languageCode?.identifier else {
            return Constants.Locale.enLanguage
        }
        return languageCode
    }

}
