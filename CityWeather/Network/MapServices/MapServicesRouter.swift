//
//  MapServicesRouter.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

public enum MapServicesRouter: NetworkCall {
    case getDataWeather(city: String)
    case getDataForecast(city: String)

    var path: URLComponents {
        var components = URLComponents()
        components.scheme = HTTPScheme.secure
        components.host = MapServicesEndpoints.environment
        components.path = switch self {
        case .getDataWeather: MapServicesEndpoints.dataWeather
        case .getDataForecast: MapServicesEndpoints.dataForecast
        }
        components.queryItems = queryItems()
        return components
    }

    var method: String { HTTPMethod.get }
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    
    private func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: "appid", value: MapServicesEndpoints.appid)]
        switch self {
        case .getDataWeather(let city), .getDataForecast(let city):
            items.append(contentsOf: [URLQueryItem(name: "q", value: city),
                                      URLQueryItem(name: "units", value: MapServicesEndpoints.units),
                                      URLQueryItem(name: "lang", value: MapServicesEndpoints.language)])
        }
        
        return items
    }
    
    
}
