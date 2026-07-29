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
        let decoder = JSONDecoder()
        return try decoder.decode(MapWrapper.self, from: mockData)
    }
    
    func getDataForecast(city: String) async throws -> MapForecastWrapper {
        let mockData = try MocksManager.shared.getMockDataForecast()
        let decoder = JSONDecoder()
        return try decoder.decode(MapForecastWrapper.self, from: mockData)
    }
}
