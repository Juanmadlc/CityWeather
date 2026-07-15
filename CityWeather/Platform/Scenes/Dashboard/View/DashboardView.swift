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

    init(viewModel: ViewModel, connector: DashboardConnector) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
    }

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(mapServicesUseCaseFactory: MapServicesUseCaseFactory()), connector: DashboardConnector())
}
