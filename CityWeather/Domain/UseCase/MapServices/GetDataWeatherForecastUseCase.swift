//
//  GetDataWeatherForecastUseCase.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/7/26.
//

import Foundation

struct GetDataWeatherForecastUseCase: AsyncUseCase {
    
    private let modelProtocol: MapServicesModelProtocol
    private let city: String
    
    init(modelProtocol: MapServicesModelProtocol, city: String) {
        self.modelProtocol = modelProtocol
        self.city = city
    }
    
    func execute() async throws -> Any {
        try await modelProtocol.getDataForecast(city: city)
    }
}
