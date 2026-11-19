//
//  ErrorWeatherView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/07/2026.
//

import SwiftUI

struct ErrorWeatherView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
}

struct ErrorWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorWeatherView(message: "Ocurrió un error al seleccionar la ciudad, comprueba la conexión o cambia de ciudad desde ajustes")
    }
}
