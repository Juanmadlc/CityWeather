//
//  MapServicesRouter.swift.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

public enum MapServicesRouter: NetworkCall {
    case getDataWeather(city: String)

    var path: URLComponents {
        var components = URLComponents()
        components.scheme = HTTPScheme.secure
        components.host = MapServicesEndpoints.environment
        components.path = {
            switch self {
            case .getDataWeather:
                return MapServicesEndpoints.dataWeather
            }
        }()
        components.queryItems = queryItems()
        return components
    }

    var method: String { return HTTPMethod.get }
    
    private func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        switch self {
        case .getDataWeather(let city):
            items.append(contentsOf: [URLQueryItem(name: "lineaId", value: line),
                                      URLQueryItem(name: "viaId", value: via),
                                      URLQueryItem(name: "version", value: "2")])
        }
        
        return items
    }
    
    
}
