import SwiftUI

struct CustomButton: View {
    var title: LocalizedStringKey
    var color: Color = .blue
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                ).overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
    }
}
