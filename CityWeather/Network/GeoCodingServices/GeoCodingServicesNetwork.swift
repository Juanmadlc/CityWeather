//
//  GeoCodingNetwork.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

final class GeoCodingServicesNetwork: NetworkDispatcher, GeoCodingServicesNetworkProtocol, Sendable {
    let baseURL: String
    let session: URLSession
    
    init(baseURL: String) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: NetworkManager.urlSessionConfiguration)
    }
    
    func getDataSearch(name: String) async throws -> Data {
        try await call(endpoint: GeoCodingServicesRouter.getDataSearch(name: name))
    }
}
