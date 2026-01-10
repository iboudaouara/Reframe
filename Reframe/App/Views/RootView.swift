import SwiftUI

struct RootView: View {
    
    @Environment(UserSession.self) private var session

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
        }
    }
}
