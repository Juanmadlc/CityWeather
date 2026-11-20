//
//  CitySelectionView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import SwiftUI

struct CitySelectionView<ViewModel>: View where ViewModel: CitySelectionViewModelProtocol {
    
    @StateObject private var viewModel: ViewModel
    @Environment(\.openURL) private var openURL
    private let connector: CitySelectionConnector
    private let navBarTitle = Constants.Config.cityWeather
    
    @State private var searchText = ""

    private var displayedCities: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return viewModel.citySuggestions
    }
    
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
                ScrollView {
                    VStack {
                        subtitleView
                        
                        UseCurrentLocationButton(action: {
                            Task {
                                let current = await viewModel.getCurrentCity() ?? ""
                                self.searchText = current
                            }
                        }).padding(.bottom, 8)
                        
                        SearchBar(text: $searchText)
                            .padding(.bottom, 16)
                        
                        CityList(cities: displayedCities, onSelect: { selected in
                            viewModel.didTapContinue(city: selected)
                        })
                        .padding(.bottom, 16)

                    }.padding(.horizontal, 24)

                }
            }
        }
        .commonsNavigationBar(title: navBarTitle)
        .navigationDestination(isPresented: $viewModel.shouldNavigateToDashboard) {
            connector.navigateToDashboard(city: viewModel.dashboardCity, country: viewModel.dashboardCountry)
        }
        .alert("Location unavailable", isPresented: $viewModel.shouldShowLocationDeniedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Go to Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            }
        } message: {
            Text("You have denied access to your location. To use your current location, you can enable it in Settings.")
        }
        .onDisappear {
            viewModel.resetLoading()
        }
        .onChange(of: viewModel.shouldNavigateToDashboard) { _, isShowingDashboard in
            guard !isShowingDashboard else { return }
            viewModel.didReturnFromDashboard()
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.loadCitySuggestions(name: newValue)
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
                Image(systemName: "location.fill")
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
                if city != cities.last {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        var dashboardCountry: String = ""
        var isLoading: Bool = false
        var citySuggestions: [String] = []
        var shouldShowLocationDeniedAlert = false
        let cities = [
            "New York",
            "London",
            "Paris",
            "Tokyo",
            "Madrid",
            "Rome"
        ]

        func onAppear() {}

        func getCurrentCity() async -> String? {
            "Barcelona"
        }

        func didTapContinue(city: String) {
            dashboardCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
            shouldNavigateToDashboard = true
        }
        
        func loadCitySuggestions(name: String) {
            citySuggestions = [
                "Madrid, España",
                "Madrigal de la Vera, España",
                "Madridejos, España"
            ]
        }
        
        func resetLoading() {return}

        func didReturnFromDashboard() {}
    }

    class PreviewCitySelectionConnector: CitySelectionConnector {}

    static let viewModel = PreviewCitySelectionViewModel()
    static let connector = PreviewCitySelectionConnector()

    static var previews: some View {
        CitySelectionView(viewModel: viewModel, connector: connector)
    }
}
