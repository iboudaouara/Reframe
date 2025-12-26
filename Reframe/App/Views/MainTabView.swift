import SwiftUI

struct MainTabView: View {
    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            StrategicDashboardView()
                .tabItem { Label("Tactical", systemImage: "shield.righthalf.filled") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }

            /*
             InsightView()
             .tabItem {
             Label("Insight", systemImage: "lightbulb")
             }
             */
        }
        .task(id: session.user?.id) {
            guard session.user != nil else { return }
            await session.synchronize(modelContext: modelContext)
        }
    }
}

#Preview {
    let sess = Session()
    MainTabView()
        .environment(sess)
}
