//
//  CitySelectionConnector.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 22/06/2026.
//

import Foundation
import SwiftUI

@MainActor
class CitySelectionConnector {
    func assembleModule() -> some View {
        let viewModel = CitySelectionViewModel()
     
        return CitySelectionView(viewModel: viewModel, connector: self)
    }

    func navigateToDashboard(city: String) -> some View {
        DashboardConnector().assembleModule(city: city)
    }
}
