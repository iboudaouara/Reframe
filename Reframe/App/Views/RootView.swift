import SwiftUI

struct RootView: View {
    @Environment(UserSession.self) private var userSession

    var body: some View {
        Group {
            switch userSession.state {
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

#Preview {
    let userSession = UserSession()

    RootView()
        .environment(userSession)
        .environment(\.locale, .init(identifier: "fr"))
}


