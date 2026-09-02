//
//  GeoCodingServicesModelProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

enum GeoCodingServicesModelProtocolError: Error {
    case unaccessible
}

protocol GeoCodingServicesModelProtocol {
    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper
}

