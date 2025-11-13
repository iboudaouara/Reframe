import SwiftUI

struct CustomTextField: View {
    var placeholder: LocalizedStringKey
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .foregroundColor(.white)
        .frame(maxWidth: 380)
    }
}
