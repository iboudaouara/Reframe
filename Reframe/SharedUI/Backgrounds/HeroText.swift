import SwiftUI

struct HeroText: View {

    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(.system(size: 40, weight: .medium))
            .lineLimit(3)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.5)
            .padding(.bottom, 20)
    }
}
