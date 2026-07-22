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
    // MARK: - Properties
    private var mapServicesUseCaseFactory: MapServicesUseCaseFactory
    private var mapWrapper: MapWrapper?
  
    init(mapServicesUseCaseFactory: MapServicesUseCaseFactory) {
        self.mapServicesUseCaseFactory = mapServicesUseCaseFactory
    }

    // MARK: - Fetchs
    @MainActor func fetchDataWeather(city: String) async {
        do {
            let useCase = mapServicesUseCaseFactory.getDataWeather(city: city)
            mapWrapper = try await useCase.execute() as? MapWrapper
        } catch {
            Log.error("Error: \(error)")
        }
    }}
