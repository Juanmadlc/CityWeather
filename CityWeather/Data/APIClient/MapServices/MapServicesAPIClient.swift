//
//  MapServicesAPIClient.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class MapServicesAPIClient: MapServicesAPIClientProtocol {
    // MARK: - Properties
    private var network: MapServicesNetworkProtocol
    
    init(network: MapServicesNetworkProtocol) {
        self.network = network
    }
    
    // MARK: - Functions
    func getDataWeather(city: String) async throws -> MapWrapper {
        let response = try await network.getDataWeather(city: city)
        return try JSONDecoder().decode(MapWrapper.self, from: response)
    }
    
    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        let response = try await network.getDataForecast(city: city)
        return try JSONDecoder().decode(MapForecastWrapper.self, from: response)
    }
    
}
