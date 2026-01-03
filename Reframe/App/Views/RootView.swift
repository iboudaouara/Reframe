import SwiftUI

struct RootView: View {
    
    @Environment(Session.self) private var session

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                LoadingView()
            case .authenticated, .guest:
                MainTabView()
            case .unauthenticated:
                AuthView()
            }
        }.task {
            // C'est ici que la vérification se fait, de manière sécurisée et liée au cycle de vie
            await session.restorePreviousSession()
        }
    }
}
