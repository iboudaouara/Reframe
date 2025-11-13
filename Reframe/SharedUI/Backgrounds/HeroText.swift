import SwiftUI

struct HeroText: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(.system(size: 40, weight: .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 24)
            .shadow(color: .black, radius: 8)
            .frame(alignment: .leading)
    }
}
