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
    @Environment(\.scenePhase) var scenePhase
    
    init(viewModel: ViewModel, connector: DashboardConnector, city: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
        self.city = city
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let displayModel = viewModel.weatherDisplayModel {
                    TemperatureView(model: displayModel)
                    if !displayModel.hourlyForecast.isEmpty {
                        TimeHoursView(hours: displayModel.hourlyForecast)
                            .padding(.top, 40)
                    }
                } else {
                    ProgressView()
                }
                Spacer()
            }
        }
        .commonsNavigationBar(title: city) {
            Button(action: {
                // TODO: 01 Acción para abrir pantalla de Ajustes (Settings)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.systemGray2))
            }
        }
        .task {
            await viewModel.fetchDataWeather(city: city)
            await viewModel.fetchDataWeatherForecast(city: city)
        }
        
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.fetchDataWeather(city: city)
                    await viewModel.fetchDataWeatherForecast(city: city)
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
    let hours: [HourlyForecast]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<hours.count, id: \.self) { index in
                    let hour = hours[index]
                    VStack(spacing: 8) {
                        Text(hour.time)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        Image(systemName: hour.icon)
                            .font(.system(size: 22))
                            .foregroundColor(hour.color)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .padding(.horizontal, 20)
    }
}

// MARK: Preview
struct DashboardView_Previews: PreviewProvider {
    class PreviewDashboardViewModel: DashboardViewModelProtocol {
        var weatherDisplayModel: WeatherDisplayModel? = .init(temp: "28°", description: "Sunny", minTemp: "22°", maxTemp: "32°", hourlyForecast: [
            .init(time: "Now", icon: "sun.max.fill", color: .yellow),
            .init(time: "1 PM", icon: "sun.max.fill", color: .yellow),
            .init(time: "2 PM", icon: "cloud.sun.fill", color: .orange),
            .init(time: "3 PM", icon: "cloud.fill", color: .gray),
            .init(time: "4 PM", icon: "moon.fill", color: .indigo)
        ])
        
        func fetchDataWeather(city: String) async {
            return
        }
        
        func fetchDataWeatherForecast(city: String) async {
            return
        }
    }
    
    class PreviewDashboardConnector: DashboardConnector {}
    
    static let viewModel = PreviewDashboardViewModel()
    static let connector = PreviewDashboardConnector()
    
    static var previews: some View {
        DashboardView(viewModel: viewModel, connector: connector, city: "Barcelona")
    }
}
