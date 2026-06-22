//
//  ContentView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import SwiftUI

struct CitySelectionView<ViewModel>: View where ViewModel: CitySelectionViewModelProtocol {
    
    @StateObject private var viewModel: ViewModel
    private let connector: CitySelectionConnector
    private let navBarTitle = "City Weather"
    
    init(viewModel: ViewModel, connector: CitySelectionConnector) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("City Selection")
        }
        .navigationTitle(navBarTitle)
        .padding()
    }
}

struct CitySelectionView_Previews: PreviewProvider {
    class MySeasonViewViewModel: CitySelectionViewModelProtocol {
    }
    class PreviewMySeasonConnector: CitySelectionConnector {}
    
    static let viewModel = MySeasonViewViewModel()
    static let connector = PreviewMySeasonConnector()
    
    static var previews: some View {
        CitySelectionView(viewModel: viewModel, connector: connector)
    }
}
