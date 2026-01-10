import SwiftUI
import SwiftData

struct AuthView: View {

    @Environment(UserSession.self) private var session
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {

                    HomeBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            Spacer()

                            VStack(spacing: 24) {

                                HeroText(text: "home.hero.title")

                                CarouselFeatures()

                            }
                            .padding(.horizontal, 24)

                            Spacer()

                            VStack(spacing: 16) {

                                HStack {
                                    AppButton("Login", style: .primary) {
                                        path.append(AppDestination.login)
                                    }
                                    .foregroundStyle(.primary)
                                    AppButton("Sign Up", style: .secondary) {
                                        path.append(AppDestination.signup)
                                    }
                                }
                                Separator(text: "Or")
                                AppleSignInButton().task {
                                    try? modelContext.delete(model: TacticalAnalysis.self)
                                    await session.synchronize(modelContext: modelContext)
                                }

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
                            .frame(maxWidth: 400)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        }
                        .frame(minHeight: geometry.size.height)
                        .frame(width: geometry.size.width)
                    }.frame(width: geometry.size.width)
                }.frame(width: geometry.size.width)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .login: LoginView()
                case .signup: SignUpView()
                }
            }
        }
    }
}


