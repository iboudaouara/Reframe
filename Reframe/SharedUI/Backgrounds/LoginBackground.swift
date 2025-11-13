import SwiftUI

struct LoginBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.blue, Color.white],
            startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
    }
}
