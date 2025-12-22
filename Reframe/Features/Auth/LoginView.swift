import SwiftUI

struct LoginView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(Session.self) private var session
    
    private var isShowingAlert: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { _,_ in errorMessage = nil }
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DiagonalBackground()

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
                            mode: .login,
                            onSubmit: handleLogin
                        )

                        LegalFooterView()
                        Spacer()
                    }.frame(minHeight: geo.size.height)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).ignoresSafeArea()

                }
            }
        }.ignoresSafeArea()
        .alert("Login Failed", isPresented: isShowingAlert) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "An unexpected error occurred.")
        }
    }
    
    private func handleLogin() {
        Task {
            isLoading = true
            do {
                try await session.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}




#Preview {
    let session = Session()
    LoginView()
        .environment(session)
}
