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
    
    init(viewModel: ViewModel, connector: DashboardConnector, city: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
        self.city = city
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TemperatureView()
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
    }
}

// MARK: - Components

struct TemperatureView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("28°")
                .font(.system(size: 78, weight: .light))
                .foregroundColor(.primary)
            
            Text("Sunny")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Text("H: 32°  L: 22°")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

// MARK: Preview
struct DashboardView_Previews: PreviewProvider {
    class PreviewDashboardViewModel: DashboardViewModelProtocol {
        
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
