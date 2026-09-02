//
//  GeoCodingServicesRepository.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

final class GeoCodingServicesRepository: GeoCodingServicesModelProtocol {
    
    private let apiClient: GeoCodingServicesAPIClientProtocol
    
    init(apiClient: GeoCodingServicesAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        return try await apiClient.getDataSearch(name: name)
    }
    
    
}
