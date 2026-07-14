//
//  SearchBar.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 08/07/2026.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)

                TextField("Search for a city", text: $text)
                    .focused($isFocused)
                    .font(.system(size: 16))
                    .padding(.vertical, 8)

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 8)
                }
            }
            .frame(height: 44)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)

            if isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                }
            }
        }
        .padding(.top, 4)
        .animation(.default, value: isFocused)
    }
}
