//
//  MockGeoCodingServicesAPIClient.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 03/09/2026.
//

import Foundation

final class MockGeoCodingServicesAPIClient: GeoCodingServicesAPIClientProtocol {
    
    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        let mockData = try MocksManager.shared.getMockGeoDataSearch()
        let decoder = JSONDecoder()
        return try decoder.decode(GeoCodingSearchWrapper.self, from: mockData)
    }
    
}
