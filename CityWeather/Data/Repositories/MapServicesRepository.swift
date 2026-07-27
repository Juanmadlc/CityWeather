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
        if MocksManager.shared.shouldUseMockData() {
            let mockData = try MocksManager.shared.getMockDataWeather()
            let decoder = JSONDecoder()
            return try decoder.decode(MapWrapper.self, from: mockData)
        }
        return try await apiClient.getDataWeather(city: city)
    }
    
    func getDataForecast(city: String) async throws -> MapForestWrapper {
        if MocksManager.shared.shouldUseMockData() {
            let mockData = try MocksManager.shared.getMockDataForecast()
            let decoder = JSONDecoder()
            return try decoder.decode(MapForestWrapper.self, from: mockData)
        }
        return try await apiClient.getDataForecast(city: city)
    }
    
}
