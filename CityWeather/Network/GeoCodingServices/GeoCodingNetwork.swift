//
//  GeoCodingNetwork.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

class GeoCodingNetwork: NetworkManager, GeoCodingNetworkProtocol {
    
    func getDataSearch(name: String) async throws -> Data {
        try await call(endpoint: GeoCodingRouter.getDataSearch(name: name))
    }
}
