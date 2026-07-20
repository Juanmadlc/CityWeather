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
        Text(city)
            .task {
                await viewModel.fetchDataWeather(city: city)
            }
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
