import SwiftUI

struct CitySelectionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("City Selection")
                .font(.title)
            Text("Selected city: \(viewModel.selectedCity)")
            Text("Language: \(viewModel.languageCode)")
        }
        .padding()
    }
}

#Preview {
    let connector = CitySelectionConnector()
    let vm = CitySelectionViewModel()
    return CitySelectionView(viewModel: vm, connector: connector)
}
