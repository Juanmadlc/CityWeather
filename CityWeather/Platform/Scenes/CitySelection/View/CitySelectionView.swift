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
    
    @State private var searchText = ""
    // TODO: 01 CREAMOS EL ARRAY (Temporalmente aquí, en el futuro vendrá del viewModel)
    private let cities = ["New York", "New Angeles", "Chicago"]
    
    init(viewModel: ViewModel, connector: CitySelectionConnector) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack() {
                subtitleView

                UseCurrentLocationButton(action: {
                    
                })
                
                SearchBar(text: $searchText)
                
                ScrollView(showsIndicators: true) {
                    CityList(cities: cities, onSelect: { _ in
                        
                    })
                }
                .frame(maxHeight: 300)
                
                Spacer()
                
                NextButton(title: "Continue", action: {
                    
                })
                    
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle(navBarTitle)
    }
    
    // MARK: - Subviews
    private var subtitleView: some View {
        Text("Get local weather updates.\nAllow access to your location or choose your city.")
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .padding(.top, 32)
            .padding(.bottom, 32)
    }
}


// MARK: - Components
struct UseCurrentLocationButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Use Current Location")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Components

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search for a city", text: $text)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Componente Reutilizable: Lista de Ciudades
struct CityList: View {
    let cities: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(cities.enumerated()), id: \.offset) { index, name in
                CityRow(name: name) {
                    onSelect(name)
                }
                if index < cities.count - 1 {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CityRow: View {
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: Preview
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

