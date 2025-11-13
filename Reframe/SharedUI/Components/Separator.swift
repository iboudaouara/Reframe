import SwiftUI

struct Separator: View {
    var text: LocalizedStringKey = "Separator"
    var color: Color = .gray.opacity(0.3)

    var body: some View {
        HStack {
            line
            Text(text)
                .foregroundColor(.gray)
                .font(.footnote)

            line
        }
        .padding(.vertical, 8)
    }

    private var line: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(color)
    }
}

#Preview {
    Separator(text: "Exemple")
}
