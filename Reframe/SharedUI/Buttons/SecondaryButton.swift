import SwiftUI

struct SecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    init(title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: {
            print("SecondaryButton tapped: \(title)")
            action()
        }) {
            buttonContent
        }
    }

    private var buttonContent: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    Color.white
                }
            )
            .overlay(
                Capsule().stroke(Color.black, lineWidth: 1)
            )
            .clipShape(Capsule())
            .frame(maxWidth: 160)
    }
}
