//
//  DataServiceCloudEndpoints.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

struct DataServiceCloudEndpoints {
    static var environment: String {
        switch Bundle.main.apiEnvironment {
            case .dev: return devEnvironment
            case .pro: return proEnvironment
        }
    }
    static var language = "es" // TODO: 01 Revisar el idioma es, en ...
    static let devEnvironment = "http://api.openweathermap.org/data/2.5/weather" // TODO: O1 Cambiar
    static let proEnvironment = "http://api.openweathermap.org/data/2.5/weather"
}
