//
//  CitySelectionView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import SwiftUI

struct CitySelectionView<ViewModel>: View where ViewModel: CitySelectionViewModelProtocol {
    
    @StateObject private var viewModel: ViewModel
    private let connector: CitySelectionConnector
    private let navBarTitle = Constants.Config.cityWeather
    
    @State private var searchText = ""

    private var filteredCities: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return cities }
        
        let normalizedTokens = query
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)

        return cities.filter { city in
            let haystack = city
                .folding(options: .diacriticInsensitive, locale: .current)
                .lowercased()
            return normalizedTokens.allSatisfy { token in haystack.contains(token) }
        }
    }
    // TODO: 01 CREAMOS EL ARRAY (Temporalmente aquí, en el futuro vendrá del viewModel)
    private let cities = [
        "New York",
        "Los Angeles",
        "Chicago",
        "Houston",
        "Phoenix",
        "Philadelphia",
        "San Antonio",
        "San Diego",
        "Dallas",
        "Miami"
    ]
    
    init(viewModel: ViewModel, connector: CitySelectionConnector) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.connector = connector
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                VStack {
                    subtitleView
                    
                    UseCurrentLocationButton(action: {
                        Task {
                            let current = await viewModel.getCurrentCity() ?? ""
                            self.searchText = current
                        }
                    })
                    
                    SearchBar(text: $searchText)
                        .padding(.bottom, 16)
                    
                    ScrollView {
                        CityList(cities: filteredCities, onSelect: { selected in
                            self.searchText = selected
                        })
                    }
                    .cornerRadius(12)
                    .clipped()
                    
                    NextButton(title: "Continue", action: {
                        viewModel.didTapContinue(city: searchText)
                    }).padding(.top, 16)
                    
                }
                .padding(.horizontal, 24)
            }
        }
        .commonsNavigationBar(title: navBarTitle)
        .navigationDestination(isPresented: $viewModel.shouldNavigateToDashboard) {
            connector.navigateToDashboard(city: viewModel.dashboardCity)
        }
        .task {
            viewModel.onAppear()
        }
    }
    
    // MARK: - Subviews
    private var subtitleView: some View {
        Text("Get local weather updates.\nAllow access to your location or choose your city.")
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(6)
            .fixedSize(horizontal: false, vertical: true)
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

struct CityList: View {
    let cities: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        LazyVStack {
            ForEach(cities, id: \.self) { city in
                CityRow(name: city) {
                    onSelect(city)
                }
                Divider().padding(.leading, 16)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .frame(maxHeight: .infinity)
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
            .padding(16)
        }
    }
}


// MARK: Preview
struct CitySelectionView_Previews: PreviewProvider {
    class PreviewCitySelectionViewModel: CitySelectionViewModelProtocol {
        @Published var shouldNavigateToDashboard: Bool = false
        var dashboardCity: String = ""
        var isLoading: Bool = false

        func onAppear() {}

        func getCurrentCity() async -> String? {
            "Barcelona"
        }

        func didTapContinue(city: String) {
            dashboardCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
            shouldNavigateToDashboard = true
        }
    }

    class PreviewCitySelectionConnector: CitySelectionConnector {}

    static let viewModel = PreviewCitySelectionViewModel()
    static let connector = PreviewCitySelectionConnector()

    static var previews: some View {
        CitySelectionView(viewModel: viewModel, connector: connector)
    }
}
