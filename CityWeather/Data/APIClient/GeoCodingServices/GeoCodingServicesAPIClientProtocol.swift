//
//  GeoCodingServicesAPIClientProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

protocol GeoCodingServicesAPIClientProtocol {
    func getDataSearch(name: String) async throws -> MapWrapper
}
