//
//  DashboardViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import Foundation

protocol DashboardViewModelOutput: ObservableObject {
}

protocol DashboardViewModelInput: ObservableObject {
    func fetchDataWeather(city: String) async
}

protocol DashboardViewModelProtocol: DashboardViewModelOutput, DashboardViewModelInput {}

class DashboardViewModel: DashboardViewModelProtocol {
        
    private var mapServicesUseCaseFactory: MapServicesUseCaseFactory
  
    init(mapServicesUseCaseFactory: MapServicesUseCaseFactory) {
        self.mapServicesUseCaseFactory = mapServicesUseCaseFactory
    }
    
    
    // MARK: Output Functions
    // MARK: - Fetchs
    @MainActor func fetchDataWeather(city: String) async {
        do {
            let useCase = mapServicesUseCaseFactory.getDataWeather(city: city)
            _ = try await useCase.execute()
        } catch {
            Log.error("Error: \(error)")
        }
    }
}
