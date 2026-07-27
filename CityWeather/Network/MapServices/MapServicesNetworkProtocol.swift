//
//  MapServicesNetworkProtocol.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

protocol MapServicesNetworkProtocol {
    func getDataWeather(city: String) async throws -> Data
    func getDataForecast(city: String) async throws -> Data
}
