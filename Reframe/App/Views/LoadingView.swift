import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView(LocalizedStringKey("Checking your session..."))
                .progressViewStyle(.circular)
                .padding()
            Text("Reframe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingView()
}
