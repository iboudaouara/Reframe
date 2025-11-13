import SwiftUI
import SwiftData

@main
struct ReframeApp: App {
    private let session = UserSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.userSession, session)
                .modelContainer(for: Insight.self)
        }
    }
}

struct RootView: View {
    @Environment(\.userSession) var session

    var body: some View {
        Group {
            if session.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

struct MainTabView: View {

    @Environment(\.userSession) var session: UserSession

    var body: some View {
        TabView {
            InsightView()
                .tabItem {
                    Label("Insight", systemImage: "lightbulb")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
