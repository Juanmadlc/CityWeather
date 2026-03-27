//
//  MapServicesAPIClientProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

protocol MapServicesAPIClientProtocol {
    func getDataWeather(city: String) async throws -> MapWrapper
}
