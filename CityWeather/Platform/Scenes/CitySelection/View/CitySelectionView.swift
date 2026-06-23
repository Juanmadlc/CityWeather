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
            
            VStack(spacing: 24) {
                    Text("City Weather")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 32)
                    Text("Get local weather updates.\nAllow access to your location or choose your city.")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
             
                // TODO: Botón de Ubicación Actual
                Button(action: {
                    // Acción de localización aquí
                }) {
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
                }
                
                // 3. Barra de Búsqueda
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search for a city", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // 4. Lista de Ciudades (Diseño de tarjeta agrupada)
                VStack(spacing: 0) {
                    CityRow(name: "New York") {
                        // Acción al pulsar
                    }
                    Divider().padding(.leading, 16)
                    
                    CityRow(name: "New Angeles") {
                        // Acción al pulsar
                    }
                    Divider().padding(.leading, 16)
                    
                    CityRow(name: "Chicago") {
                        // Acción al pulsar
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                Spacer()
                
                // 5. Botón de Continuar
                Button(action: {
                    // Acción de continuar
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 24)
        }
        // Ocultamos la navigation bar nativa si el título ya está integrado en el diseño central
        .navigationBarHidden(true)
    }
}

// MARK: - Componente Reutilizable: Fila de Ciudad
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
