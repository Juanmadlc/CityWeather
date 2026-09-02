//
//  GeoCodingRouter.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

public enum GeoCodingServicesRouter: NetworkCall {
    case getDataSearch(name: String)

    var path: URLComponents {
        var components = URLComponents()
        components.scheme = HTTPScheme.secure
        components.host = MapServicesEndpoints.environment
        components.path = switch self {
        case .getDataSearch: GeoCodingServicesEndPoints.dataSearch
        }
        components.queryItems = queryItems()
        return components
    }

    var method: String { return HTTPMethod.get }
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    
    private func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        switch self {
        case .getDataSearch(let name):
            items.append(contentsOf: [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "count", value: GeoCodingServicesEndPoints.count),
                URLQueryItem(name: "language", value: GeoCodingServicesEndPoints.language)
            ])
        }
        
        return items
    }
    
    
}
