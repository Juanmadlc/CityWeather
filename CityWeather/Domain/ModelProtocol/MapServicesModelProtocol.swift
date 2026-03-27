//
//  MapServicesModelProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

enum MapServicesModelProtocolError: Error {
    case unaccessible
}

protocol MapServicesModelProtocol {
    func getDataWeather(city: String) async throws -> MapWrapper
}
