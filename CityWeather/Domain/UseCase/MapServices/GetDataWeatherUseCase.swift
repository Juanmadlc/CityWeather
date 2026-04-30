//
//  GetDataWeatherUseCase.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 30/04/2026.
//

import Foundation

final class GetDataWeatherUseCase: AsyncUseCase {
    // MARK: - Properties
    let modelProtocol: MapServicesModelProtocol
    private let city: String

    // MARK: - Init
    init(modelProtocol: MapServicesModelProtocol, city: String) {
        self.modelProtocol = modelProtocol
        self.city = city
    }

    // MARK: - Execute
    func execute() async throws -> MapWrapper {
        try await modelProtocol.getDataWeather(city: city)
    }
}
