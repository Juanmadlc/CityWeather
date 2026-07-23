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
        VStack(spacing: 0) {
            if let displayModel = viewModel.weatherDisplayModel {
                TemperatureView(model: displayModel)
            } else {
                ProgressView() // TODO: 01 Implementar mensaje Ocurrió un error con la ciudad escogida puedes cambiar la ciudad desde Ajustes , e implementar para pulsar en ajustes
            }
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
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
        }
        
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.fetchDataWeather(city: city)
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

// MARK: Preview
struct DashboardView_Previews: PreviewProvider {
    class PreviewDashboardViewModel: DashboardViewModelProtocol {
        var weatherDisplayModel: WeatherDisplayModel? = .init(temp: "28°", description: "Sunny", minTemp: "22°", maxTemp: "32°")
        
        func fetchDataWeather(city: String) async {
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
