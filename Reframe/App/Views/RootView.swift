import SwiftUI
import SwiftData

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
        }
    }
}
