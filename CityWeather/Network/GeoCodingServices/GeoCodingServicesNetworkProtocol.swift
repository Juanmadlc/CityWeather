//
//  GeoCodingNetworkProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation


protocol GeoCodingServicesNetworkProtocol {
    func getDataSearch(name: String) async throws -> Data
}
