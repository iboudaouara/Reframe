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
        }
        .task(id: session.user?.id) {
            guard session.user != nil else { return }
            await session.synchronize(modelContext: modelContext)
        }
    }
}

#Preview {
    let session = Session()
    MainTabView()
        .environment(session)
}
