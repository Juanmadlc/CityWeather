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
        let repository = MapServicesRepository(apiClient: Self.makeAPIClient())
        self.modelProtocol = repository
    }
    
    private static func makeAPIClient() -> MapServicesAPIClientProtocol {
        if MocksManager.shared.shouldUseMockData() {
            return MockMapServicesAPIClient()
        } else {
            let apiNetwork = MapServicesNetwork(baseURL: MapServicesEndpoints.environment)
            return MapServicesAPIClient(network: apiNetwork)
        }
    }
    
    
    // MARK: - Factory methods
    func getDataWeather(city: String) -> any AsyncUseCase {
        GetDataWeatherUseCase(modelProtocol: modelProtocol, city: city)
    }
    
    func getDataWeatherForecast(city: String) -> any AsyncUseCase {
        GetDataWeatherForecastUseCase(modelProtocol: modelProtocol, city: city)
    }
    
}
