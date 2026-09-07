//
//  MockMapServicesAPIClient.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 29/07/2026.
//

import Foundation

final class MockMapServicesAPIClient: MapServicesAPIClientProtocol {
    
    func getDataWeather(city: String) async throws -> MapWrapper {
        let mockData = try MocksManager.shared.getMockDataWeather()
        return try JSONDecoder().decode(MapWrapper.self, from: mockData)
    }
    
    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        let mockData = try MocksManager.shared.getMockDataForecast()
        return try JSONDecoder().decode(MapForecastWrapper.self, from: mockData)
    }
}
