//
//  GeoCodingServicesAPIClient.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

final class GeoCodingServicesAPIClient: GeoCodingServicesAPIClientProtocol {
    // MARK: - Properties
    private var network: GeoCodingServicesNetworkProtocol
    
    init(network: GeoCodingServicesNetworkProtocol) {
        self.network = network
    }
    
    // MARK: - Functions
    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        let response = try await network.getDataSearch(name: name)
        return try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: response)
    }
    
}
