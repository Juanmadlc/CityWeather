//
//  GeoCodingServicesRepository.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

final class GeoCodingServicesRepository: GeoCodingServicesModelProtocol, Sendable {
    
    private let apiClient: GeoCodingServicesAPIClientProtocol
    private let cache: GeoCodingSearchCache
    
    init(apiClient: GeoCodingServicesAPIClientProtocol, cache: GeoCodingSearchCache = GeoCodingSearchCache()) {
        self.apiClient = apiClient
        self.cache = cache
    }
    
    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        if let cached = await cache.value(for: name) {
            return cached
        }
        let result = try await apiClient.getDataSearch(name: name)
        await cache.store(result, for: name)
        return result
    }
    
}
