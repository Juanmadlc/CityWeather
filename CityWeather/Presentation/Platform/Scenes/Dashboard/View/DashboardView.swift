//
//  DashboardView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import SwiftUI

struct DashboardView<ViewModel>: View where ViewModel: DashboardViewModelProtocol {
    @StateObject private var viewModel: ViewModel
    private let connector: DashboardConnector
    private let city: String
    private let country: String
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: ViewModel, connector: DashboardConnector, city: String, country: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
        self.city = city
        self.country = country
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.hasError {
                        ErrorWeatherView(message: "Ocurrió un error al seleccionar la ciudad, comprueba la conexión o cambia de ciudad desde ajustes")
                    } else if let displayModel = viewModel.weatherDisplayModel, !displayModel.hourlyForecast.isEmpty {
                        TemperatureView(model: displayModel)
                        TimeHoursView(hours: displayModel.hourlyForecast)
                        DayForecast(forecastDays: displayModel.dailyForecast)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .commonsNavigationBar(title: city, hideBackButton: true) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.systemGray2))
            }
        }
        .task {
            await viewModel.loadWeather(city: city, country: country)
        }
        
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.loadWeather(city: city, country: country)
                }
            }
        }
        
    }
}

// MARK: - Components

struct TemperatureView: View {
    let model: WeatherDisplayModel
    
    var body: some View {
        VStack(spacing: 4) {
            Text(model.temp)
                .font(.system(size: 78, weight: .light))
                .foregroundColor(.primary)
            
            Text(model.description)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Text("Min: \(model.minTemp)  Max: \(model.maxTemp)")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

struct TimeHoursView: View {
    let hours: [HourlyForecastModel]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<hours.count, id: \.self) { index in
                let hour = hours[index]
                
                VStack(spacing: 8) {
                    Text(hour.time)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Image(systemName: hour.icon)
                        .font(.system(size: 22))
                        .foregroundColor(hour.color)
                        .frame(height: 22)
                }
                .frame(maxWidth: .infinity)
                
                if index == 0 {
                    Divider()
                        .frame(height: 30)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct DayForecast: View {
    let forecastDays: [DailyForecastModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            
            VStack(spacing: 0) {
                ForEach(0..<forecastDays.count, id: \.self) { index in
                    forecastRow(for: forecastDays[index])
                    Divider().padding(.leading, 16)
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color(UIColor.separator).opacity(0.25),
                        lineWidth: 1
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 12, weight: .semibold))
            
            Text("5-DAY FORECAST")
                .font(.system(size: 13, weight: .semibold))
            
            Spacer()
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 4)
    }
    
    private func forecastRow(for forecast: DailyForecastModel) -> some View {
        HStack(spacing: 12) {
            Text(forecast.day)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 92, alignment: .leading)
            
            Image(systemName: forecast.icon)
                .font(.system(size: 23))
                .symbolRenderingMode(.multicolor)
                .foregroundColor(forecast.color)
                .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0)
                .frame(width: 32)
            
            Text(forecast.temperature)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 42, alignment: .trailing)
            
            Text(forecast.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
    }
}

// MARK: Preview
struct DashboardView_Previews: PreviewProvider {
    class PreviewDashboardViewModel: DashboardViewModelProtocol {
        var hasError: Bool = false
        var weatherDisplayModel: WeatherDisplayModel? = .init(temp: "28°", description: "Sunny", minTemp: "22°", maxTemp: "32°", hourlyForecast: [
            .init(time: "Now", icon: "sun.max.fill", color: .yellow),
            .init(time: "1 PM", icon: "sun.max.fill", color: .yellow),
            .init(time: "2 PM", icon: "cloud.sun.fill", color: .orange),
            .init(time: "3 PM", icon: "cloud.fill", color: .gray),
            .init(time: "4 PM", icon: "moon.fill", color: .indigo)
        ], dailyForecast: [
            .init(day: "Tuesday", temperature: "24°", description: "Mostly Sunny", icon: "sun.max.fill", color: .yellow)
        ])
        
        func loadWeather(city: String, country: String) async {
            return
        }
    }
    
    class PreviewDashboardConnector: DashboardConnector {}
    
    static let viewModel = PreviewDashboardViewModel()
    static let connector = PreviewDashboardConnector()
    
    static var previews: some View {
        DashboardView(viewModel: viewModel, connector: connector, city: "Barcelona", country: "ES")
    }
}
