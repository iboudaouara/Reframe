import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.userSession) var session

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DiagonalBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Spacer()
                        LoginHeaderView()

                        LoginFormView(email: $email, password: $password, mode: .login, onSubmit: {
                            print("Sign in tapped")
                            session.login(email: email, password: password)
                        })

                        LegalFooterView()
                        Spacer()
                    }.frame(minHeight: geo.size.height)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).ignoresSafeArea()

                }
            }
        }.ignoresSafeArea()
    }
}

enum AuthMode {
    case login
    case signup
}


#Preview {
    let session = UserSession()
    LoginView()
        .environment(\.userSession, session)
}




