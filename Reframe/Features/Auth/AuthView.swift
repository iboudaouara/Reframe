import SwiftUI

struct AuthView: View {
    
    @State private var path = NavigationPath()
    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {
                    HomeBackground()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            Spacer()
                            
                            // --- ZONE BRANDING ---
                            HeroText(text: "home.hero.title")
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                            
                            // --- CARROUSEL ---
                            CarouselFeatures()
                                .frame(height: 200)
                            
                            Spacer()
                            
                            // --- ZONE BOUTONS ---
                            VStack(spacing: 16) {
                                // 1. Login
                                PrimaryButton(title: "Login") {
                                    path.append(HomeDestination.login)
                                }
                                
                                // 2. Sign Up
                                SecondaryButton(title: "Sign Up") {
                                    path.append(HomeDestination.signup)
                                }
                                
                                // 3. Apple (On l'enveloppe pour forcer la même largeur que les autres)
                                AppleSignInButton()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 45) // Hauteur standard
                                    .clipShape(RoundedRectangle(cornerRadius: 6)) // Même arrondi que AppleSignInButton interne
                                
                                // 4. Invité
                                Button("Continue as Guest") {
                                    session.continueAsGuest(modelContext: modelContext)
                                }
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.top, 8)
                            }
                            // C'est ici qu'on contrôle la largeur de TOUS les boutons
                            .frame(maxWidth: 400)
                            .padding(.horizontal, 32)
                            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 30)
                        }
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .login: LoginView()
                case .signup: SignUpView()
                case .history: HistoryView()
                }
            }
        }
    }
    /*
     func openSheet() {
     detent = .fraction(0.4)
     showSheet = true
     }
     
     func closeSheet() {
     showSheet = false
     }
     
     func navigate(to destination: HomeDestination) {
     path.append(destination)
     closeSheet()
     }*/
}

struct HomeBottomSheet: View {
    var navigate: (HomeDestination) -> Void
    @Environment(Session.self) var session
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack {
            HStack {
                PrimaryButton(title: "Login") { navigate(.login) }
                    .accessibilityIdentifier("loginNavigationButton")
                SecondaryButton(title: "Sign Up") { navigate(.signup) }
            }
            Separator(text: "OR")
            AppleSignInButton()
            Button(action: {
                session.continueAsGuest(modelContext: modelContext)
            }) {
                Text("Continue as Guest")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 300, height: 45)
                    .background(Color.white)
                    .cornerRadius(6)
            }
        }.padding(40)
    }
}

enum HomeDestination: Hashable {
    case login
    case signup
    case history
}


#Preview {
    AuthView()
}
