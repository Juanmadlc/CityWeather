//
//  CommonsNavigationBar.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 08/07/2026.
//

import SwiftUI

struct CommonsNavigationBar<Trailing: View>: ViewModifier {
    let title: String
    let trailingView: Trailing
    let hideBackButton: Bool
    
    init(title: String, hideBackButton: Bool = false, @ViewBuilder trailingView: () -> Trailing = { EmptyView() }) {
        self.title = title
        self.hideBackButton = hideBackButton
        self.trailingView = trailingView()
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hideBackButton)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingView
                }
            }
    }
}


extension View {

    func commonsNavigationBar(title: String, hideBackButton: Bool = false) -> some View {
        modifier(CommonsNavigationBar<EmptyView>(title: title, hideBackButton: hideBackButton))
    }
    
    func commonsNavigationBar<Trailing: View>(
        title: String,
        hideBackButton: Bool = false,
        @ViewBuilder trailing: () -> Trailing) -> some View {
        modifier(CommonsNavigationBar(title: title, hideBackButton: hideBackButton, trailingView: trailing))
    }
    

}
