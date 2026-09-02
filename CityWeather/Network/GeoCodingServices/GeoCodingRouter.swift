//
//  GeoCodingRouter.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

public enum GeoCodingRouter: NetworkCall {
    case getDataSearch(name: String)

    var path: URLComponents {
        var components = URLComponents()
        components.scheme = HTTPScheme.secure
        components.host = MapServicesEndpoints.environment
        components.path = switch self {
        case .getDataSearch: GeoCodingEndPoints.dataSearch
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
                URLQueryItem(name: "count", value: GeoCodingEndPoints.count),
                URLQueryItem(name: "language", value: GeoCodingEndPoints.language)
            ])
        }
        
        return items
    }
    
    
}
