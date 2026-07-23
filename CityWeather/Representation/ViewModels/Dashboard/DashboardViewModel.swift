//
//  DashboardViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import Foundation

protocol DashboardViewModelOutput: ObservableObject {
    var weatherDisplayModel: WeatherDisplayModel? { get }
}

protocol DashboardViewModelInput: ObservableObject {
    func fetchDataWeather(city: String) async
}

protocol DashboardViewModelProtocol: DashboardViewModelOutput, DashboardViewModelInput {}

class DashboardViewModel: DashboardViewModelProtocol {
    // MARK: - Properties
    @Published var weatherDisplayModel: WeatherDisplayModel?
    private var mapServicesUseCaseFactory: MapServicesUseCaseFactory
    
    init(mapServicesUseCaseFactory: MapServicesUseCaseFactory) {
        self.mapServicesUseCaseFactory = mapServicesUseCaseFactory
    }
    
    // MARK: - Fetchs
    @MainActor func fetchDataWeather(city: String) async {
        do {
            let useCase = mapServicesUseCaseFactory.getDataWeather(city: city)
            if let wrapper = try await useCase.execute() as? MapWrapper {
                updateDisplayModel(from: wrapper)
            }
        } catch {
            Log.error("Error: \(error)")
        }
    }
    
    private func updateDisplayModel(from wrapper: MapWrapper) {
        let temp = String(format: "%.0f°", wrapper.main.temp)
        let minTemp = String(format: "%.0f°", wrapper.main.tempMin)
        let maxTemp = String(format: "%.0f°", wrapper.main.tempMax)
        let description = wrapper.weather.first?.description.capitalized ?? ""
        
        self.weatherDisplayModel = WeatherDisplayModel(
            temp: temp,
            description: description,
            minTemp: minTemp,
            maxTemp: maxTemp
        )
    }
    
}

struct WeatherDisplayModel {
    let temp: String
    let description: String
    let minTemp: String
    let maxTemp: String
}

