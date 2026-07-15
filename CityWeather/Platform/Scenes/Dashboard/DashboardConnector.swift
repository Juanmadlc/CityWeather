//
//  DashboardConnector.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 15/07/2026.
//

import SwiftUI

@MainActor
class DashboardConnector {
    func assembleModule() -> some View {
        let viewModel = DashboardViewModel(mapServicesUseCaseFactory: MapServicesUseCaseFactory())
     
        return DashboardView(viewModel: viewModel, connector: self)
    }
}

