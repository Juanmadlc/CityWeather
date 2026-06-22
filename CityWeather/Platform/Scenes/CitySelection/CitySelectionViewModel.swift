import Foundation
import SwiftUI

@MainActor
final class CitySelectionViewModel: ObservableObject {
    // Placeholder published properties; adjust to real model later
    @Published var selectedCity: String
    @Published var languageCode: String

    init(selectedCity: String = "Barcelona", languageCode: String = Locale.current.language.languageCode?.identifier ?? "en") {
        self.selectedCity = selectedCity
        self.languageCode = languageCode
    }
}
