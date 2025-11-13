import SwiftUI

struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @FocusState private var passwordFieldIsFocused: Bool

    let mode: AuthMode
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(placeholder: "Email", text: $email, isSecure: false)
            CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                .focused($passwordFieldIsFocused)

            if mode == .signup && passwordFieldIsFocused {
                PasswordCriteriaView(password: password)
            }

            CustomButton(title: mode == .login ? "Login" : "Sign Up", action: onSubmit)
        }
        .padding(.horizontal, 32)
    }
}
