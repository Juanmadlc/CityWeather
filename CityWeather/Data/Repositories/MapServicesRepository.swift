//
//  MapServicesRepository.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class MapServicesRepository:  MapServicesModelProtocol {
    
    private let apiClient: MapServicesAPIClientProtocol
    
    init(apiClient: MapServicesAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func getDataWeather(city: String) async throws -> MapWrapper {
        if MocksManager.shared.shouldUseMockData() {
            return try MocksManager.shared.getMockDataWeather()
        }
        return try await apiClient.getDataWeather(city: city)
    }
    
    
}

