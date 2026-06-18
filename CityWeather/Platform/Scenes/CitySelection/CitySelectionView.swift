//
//  ContentView.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import SwiftUI

struct CitySelectionView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("City Selection")
        }
        .padding()
    }
}

#Preview {
    CitySelectionView()
}
