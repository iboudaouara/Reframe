import SwiftUI

struct SignUpView: View {
    @Environment(Session.self) var session
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var termsAccepted: Bool = false

    @State private var firstName = ""
    @State private var lastName = ""


    private var isShowingAlert: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { _,_ in errorMessage = nil }
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LoginBackground()
                ScrollView(showsIndicators: false) {

                    VStack(spacing: 16) {
                        Spacer()
                        LoginHeaderView()

                        LoginFormView(
                            email: $email,
                            password: $password,
                            isLoading: $isLoading,
                            firstName: $firstName,
                            lastName: $lastName,
                            mode: .signup,
                            onSubmit: handleSignUp
                        )

                        AcceptTermsView(termsAccepted: $termsAccepted)
                        
                        //LegalFooterView()
                        Spacer()
                    }.frame(minHeight: geo.size.height)
                }.frame(minWidth: geo.size.width, minHeight: geo.size.height).background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }.ignoresSafeArea()
        }
        .alert("Sign Up Failed", isPresented: isShowingAlert) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "An unexpected error occurred.")
        }
    }
    
    private func handleSignUp() {

        if firstName.isEmpty || lastName.isEmpty {
            errorMessage = "Please enter your first and last name."
            return
        }

        if !EmailValidator.isValid(email) {
            errorMessage = "Please enter a valid email address."
            return
        }

        if !PasswordValidator.isValid(password) {
            errorMessage = "Your password does not meet the required criteria."
            return
        }

        if !termsAccepted {
            errorMessage = "You must agree to the Terms of Service and Privacy Policy."
            return
        }

        Task {
            isLoading = true
            do {
                try await session.signup(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    let session = Session()
    SignUpView()
        .environment(session)
}
