//
//  MapServicesRepository.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class MapServicesRepository: MapServicesModelProtocol {
    
    private let apiClient: MapServicesAPIClientProtocol
    
    init(apiClient: MapServicesAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func getDataWeather(city: String) async throws -> MapWrapper {
        return try await apiClient.getDataWeather(city: city)
    }
    
    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        return try await apiClient.getDataForecast(city: city)
    }
    
}
