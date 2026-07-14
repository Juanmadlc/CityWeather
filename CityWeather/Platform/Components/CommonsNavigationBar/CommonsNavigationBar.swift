//
//  CommonsNavigationBar.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 08/07/2026.
//

import SwiftUI

private struct CommonsNavigationBar: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 24, weight: .bold))
                }
            }
    }
}

extension View {
    func commonsNavigationBar(title: String) -> some View {
        modifier(CommonsNavigationBar(title: title))
    }
}
