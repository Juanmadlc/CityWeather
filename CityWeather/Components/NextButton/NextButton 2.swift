import SwiftUI

struct ContentView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}
