import SwiftUI

struct AuthView: View {

    @State private var showSheet = true
    @State private var detent: PresentationDetent = .fraction(0.4)
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScreenContainer {
                Spacer()
                HeroText(text: "home.hero.title")
                Spacer()
                CarouselFeatures()
                Spacer()
                CustomButton(title: "home.hero.cta", action: { openSheet() })
                Spacer()
            }.sheet(isPresented: $showSheet, onDismiss: { closeSheet()}) {
                HomeBottomSheet { destination in
                    navigate(to: destination)
                }
                .presentationDetents(
                    [.fraction(0.4), .large], selection: $detent)
            }.navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .login: LoginView()
                case .signup: SignUpView().onDisappear{ openSheet() }
                case .history: HistoryView().onDisappear{ openSheet() }
                }
            }
        }
    }

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
    }
}

struct HomeBottomSheet: View {
    var navigate: (HomeDestination) -> Void
    @Environment(UserSession.self) var session
    
    var body: some View {
        VStack {
            HStack {
                PrimaryButton(title: "Login") { navigate(.login) }
                SecondaryButton(title: "Sign Up") { navigate(.signup) }
            }
            Separator(text: "OR")
            AppleSignInButton()
            Button(action: {
                session.continueAsGuest()
            }) {
                Text("Continue as Guest")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 300, height: 45)
                    .background(Color.white)
                    .cornerRadius(6)
            }
            .padding(6)
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
