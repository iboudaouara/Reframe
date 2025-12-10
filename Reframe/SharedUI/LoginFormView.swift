import SwiftUI

struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isLoading: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    @FocusState private var passwordFieldIsFocused: Bool

    let mode: AuthMode
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            if mode == .signup {
                HStack(spacing: 12) {
                    CustomTextField(
                        placeholder: "First Name",
                        text: $firstName,
                        contentType: .givenName
                    )
                    .frame(maxWidth: .infinity)

                    CustomTextField(
                        placeholder: "Last Name",
                        text: $lastName,
                        contentType: .familyName
                    )
                    .frame(maxWidth: .infinity)
                }
            }

            CustomTextField(placeholder: "Email", text: $email, isSecure: false)
            CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                .focused($passwordFieldIsFocused)

            if mode == .signup && passwordFieldIsFocused {
                PasswordCriteriaView(password: password)
            }

            CustomButton(title: mode == .login ? "Login" : "Sign Up", action: onSubmit)
                .disabled(isLoading)
                .overlay {
                    if isLoading {
                        ProgressView()
                    }
                }
        }
        .padding(.horizontal, 32)
    }
}
