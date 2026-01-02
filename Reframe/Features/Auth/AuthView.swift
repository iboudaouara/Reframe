import SwiftUI

struct AuthView: View {
    @State private var path = NavigationPath()
    @Environment(UserSession.self) private var session
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {
                    HomeBackground() // Fond fixe

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) { // Spacing 0 car on utilise des Spacer()

                            Spacer() // Pousse vers le bas pour centrer

                            VStack(spacing: 24) {
                                // --- BRANDING ---
                                HeroText(text: "home.hero.title")
                                    .padding(.bottom, 20)

                                // --- CARROUSEL ---
                                CarouselFeatures()
                                // .frame(height: 220)
                            }
                            .padding(.horizontal, 24) // Padding global pour le haut

                            Spacer() // Équilibre l'espace

                            // --- BOUTONS ---
                            VStack(spacing: 16) {

                                HStack {
                                    PrimaryButton(title: "Login") {
                                        path.append(HomeDestination.login)
                                    }
                                    SecondaryButton(title: "Sign Up") {
                                        path.append(HomeDestination.signup)
                                    }
                                }

                                AppleSignInButton()

                                Button("Continue as Guest") {
                                    withAnimation(.easeIn(duration: 0.5)) {
                                        session.continueAsGuest(
                                            modelContext: modelContext
                                        )
                                    }
                                }

                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.top, 8)
                            }
                            // Largeur max pour iPad/Paysage, sinon prend tout l'espace moins le padding
                            .frame(maxWidth: 400)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        }
                        // C'EST ICI LA CLÉ :
                        .frame(minHeight: geometry.size.height)
                        .frame(width: geometry.size.width)
                    }.frame(width: geometry.size.width)
                }.frame(width: geometry.size.width)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .login: LoginView()
                case .signup: SignUpView()
                case .history: HistoryView()
                }
            }
        }
    }
}

enum HomeDestination: Hashable {
    case login
    case signup
    case history
}


#Preview {
    let session = UserSession()
    AuthView()
        .environment(session)
}
