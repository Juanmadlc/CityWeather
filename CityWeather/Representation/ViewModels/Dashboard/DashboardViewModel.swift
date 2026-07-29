//
//  DashboardViewModel.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import SwiftUI

protocol DashboardViewModelOutput: ObservableObject {
    var weatherDisplayModel: WeatherDisplayModel? { get }
    var hasError: Bool { get }
}

protocol DashboardViewModelInput: ObservableObject {
    func fetchDataWeather(city: String) async
    func fetchDataWeatherForecast(city: String) async
}

protocol DashboardViewModelProtocol: DashboardViewModelOutput, DashboardViewModelInput {}

class DashboardViewModel: DashboardViewModelProtocol {
    // MARK: - Properties
    @Published var weatherDisplayModel: WeatherDisplayModel?
    @Published var hasError: Bool = false
    private var mapServicesUseCaseFactory: MapServicesUseCaseFactory
    
    init(mapServicesUseCaseFactory: MapServicesUseCaseFactory) {
        self.mapServicesUseCaseFactory = mapServicesUseCaseFactory
    }
    
    // MARK: - Fetchs
    @MainActor func fetchDataWeather(city: String) async {
        hasError = false
        do {
            let useCase = mapServicesUseCaseFactory.getDataWeather(city: city)
            if let wrapper = try await useCase.execute() as? MapWrapper {
                updateDisplayModel(from: wrapper)
            }
        } catch {
            Log.error("Error: \(error)")
            hasError = true
        }
    }
    
    @MainActor func fetchDataWeatherForecast(city: String) async {
        hasError = false
        do {
            let useCase = mapServicesUseCaseFactory.getDataWeatherForecast(city: city)
            if let wrapper = try await useCase.execute() as? MapForecastWrapper {
                updateForecastDisplayModel(from: wrapper)
            }
        } catch {
            Log.error("Error: \(error)")
            hasError = true
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
            maxTemp: maxTemp,
            hourlyForecast: self.weatherDisplayModel?.hourlyForecast ?? []
        )
    }
    
    private func updateForecastDisplayModel(from wrapper: MapForecastWrapper) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h a"
        
        let forecastItems = wrapper.list.prefix(5).enumerated().map { (index, item) -> HourlyForecastModel in
            let date = formatter.date(from: item.dtTxt) ?? Date()
            let timeString = displayFormatter.string(from: date)
            let iconCode = item.weather.first?.icon ?? ""
            return HourlyForecastModel(
                time: index == 0 ? "Now" : timeString,
                icon: weatherAppearance(from: iconCode).icon,
                color: weatherAppearance(from: iconCode).color
            )
        }
        
        if self.weatherDisplayModel != nil {
            self.weatherDisplayModel?.hourlyForecast = Array(forecastItems)
        } else {
            self.weatherDisplayModel = WeatherDisplayModel(
                temp: "--°",
                description: "",
                minTemp: "--°",
                maxTemp: "--°",
                hourlyForecast: Array(forecastItems)
            )
        }
    }
    
    private func weatherAppearance(from icon: String) -> (icon: String, color: Color) {
        switch icon {
        case "01d": return ("sun.max.fill", .yellow)
        case "01n": return ("moon.fill", .indigo)
        case "02d": return ("cloud.sun.fill", .orange)
        case "02n": return ("cloud.moon.fill", .indigo)
        case "03d", "03n", "04d", "04n": return ("cloud.fill", .gray)
        case "09d", "09n", "10d", "10n": return ("cloud.rain.fill", .blue)
        case "11d", "11n": return ("cloud.bolt.rain.fill", .purple)
        case "13d", "13n": return ("snowflake", .cyan)
        case "50d", "50n": return ("cloud.fog.fill", .gray)
        default: return ("cloud.fill", .gray)
        }
    }
    
}

public struct WeatherDisplayModel {
    public let temp: String
    public let description: String
    public let minTemp: String
    public let maxTemp: String
    public var hourlyForecast: [HourlyForecastModel]
    
    public init(temp: String, description: String, minTemp: String, maxTemp: String, hourlyForecast: [HourlyForecastModel]) {
        self.temp = temp
        self.description = description
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.hourlyForecast = hourlyForecast
    }
}

public struct HourlyForecastModel {
    public let time: String
    public let icon: String
    public let color: Color
    
    public init(time: String, icon: String, color: Color) {
        self.time = time
        self.icon = icon
        self.color = color
    }
}
