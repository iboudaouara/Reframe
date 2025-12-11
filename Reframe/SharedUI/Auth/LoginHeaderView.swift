import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image("Logo")
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
            Text("ReFrame")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Text("Welcome!")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#Preview {
    LoginHeaderView()
}
