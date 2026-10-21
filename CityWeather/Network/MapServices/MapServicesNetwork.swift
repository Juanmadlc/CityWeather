//
//  MapServicesNetwork.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class MapServicesNetwork: NetworkDispatcher, MapServicesNetworkProtocol, Sendable {
    let baseURL: String
    let session: URLSession
    
    init(baseURL: String) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: NetworkManager.urlSessionConfiguration)
    }
    
    func getDataWeather(city: String) async throws -> Data {
        try await call(endpoint: MapServicesRouter.getDataWeather(city: city))
    }
    
    func getDataForecast(city: String) async throws -> Data {
        try await call(endpoint: MapServicesRouter.getDataForecast(city: city))
    }
}
