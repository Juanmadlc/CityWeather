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
    
    // MARK: PARAMS
    static var appid = "768543f20334a8c0ab4d96b800f607e5"
    static var units = "metric"
    static var language = "es"

}
