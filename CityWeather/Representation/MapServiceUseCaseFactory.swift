//
//  MapServiceUseCaseFactory.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import Foundation

class MapServicesUseCaseFactory {
    
    // MARK: - Properties
    let modelProtocol: MapServicesModelProtocol
    
    // MARK: - Init
    init(modelProtocol: MapServicesModelProtocol) {
        self.modelProtocol = modelProtocol
    }
    
    init() {
        let apiNetwork = MapServicesNetwork(baseURL: MapServicesEndpoints.environment)
        let apiClient = MapServicesAPIClient(network: apiNetwork)
        let repository = MapServicesRepository(apiClient: apiClient)
        self.modelProtocol = repository
    }
    
    
    // MARK: - Factory methods
    func getDataWeather(city: String) -> any AsyncUseCase {
        GetDataWeatherUseCase(modelProtocol: modelProtocol, city: city)
    }
    
    func getDataWeatherForecast(city: String) -> any AsyncUseCase {
        GetDataWeatherForecastUseCase(modelProtocol: modelProtocol, city: city)
    }
    
}
