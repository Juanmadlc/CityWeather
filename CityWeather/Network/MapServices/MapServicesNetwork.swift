//
//  MapServicesNetwork.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

class MapServicesNetwork: NetworkManager, MapServicesNetworkProtocol {
    
    func getDataWeather(city: String) async throws -> Data {
        try await call(endpoint: MapServicesRouter.getDataWeather(city: city))
    }
    
    func getDataForecast(city: String) async throws -> Data {
        try await call(endpoint: MapServicesRouter.getDataForecast(city: city))
    }
}
