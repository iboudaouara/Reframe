import SwiftUI
import SwiftData

@main
struct ReframeApp: App {
    @State private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .modelContainer(for: Insight.self)
        }
    }
}

struct RootView: View {
    @Environment(UserSession.self) var session

    var body: some View {
        Group {
            if session.isLoading {
                LoadingView()
            } else if session.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }.onAppear(){
            Task {
                await session.checkSessionStatus()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Vérification de la session...")
                .progressViewStyle(.circular)
                .padding()

            Text("Reframe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
struct MainTabView: View {

    @Environment(UserSession.self) var session: UserSession

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
