//
//  GeoCodingUseCaseFactory.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 03/09/2026.
//

import Foundation

class GeoCodingServiceUseCaseFactory {
    
    // MARK: - Properties
    let modelProtocol: GeoCodingServicesModelProtocol
    
    // MARK: - Init
    init(modelProtocol: GeoCodingServicesModelProtocol) {
        self.modelProtocol = modelProtocol
    }
    
    init() {
        let repository = GeoCodingServicesRepository(apiClient: Self.makeAPIClient())
        self.modelProtocol = repository
    }
    
    private static func makeAPIClient() -> GeoCodingServicesAPIClientProtocol {
        if MocksManager.shared.shouldUseMockData() {
            return GeoCodingServicesAPIClient()
        } else {
            let apiNetwork = GeoCodingServicesNetwork(baseURL: GeoCodingServicesEndPoints.environment)
            return GeoCodingServicesAPIClient(network: apiNetwork)
        }
    }
    
    
    // MARK: - Factory methods
    func getDataSearch(name: String) -> any AsyncUseCase {
        GetDataSearchUseCase(modelProtocol: modelProtocol, name: name)
    }
    
}
