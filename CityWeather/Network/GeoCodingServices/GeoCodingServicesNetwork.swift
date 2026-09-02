//
//  GeoCodingNetwork.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

class GeoCodingServicesNetwork: NetworkManager, GeoCodingServicesNetworkProtocol {
    
    func getDataSearch(name: String) async throws -> Data {
        try await call(endpoint: GeoCodingServicesRouter.getDataSearch(name: name))
    }
}
