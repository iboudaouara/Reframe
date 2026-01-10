import SwiftUI
import SwiftData

@main
struct ReframeApp: App {

    @State private var userSession = UserSession()

    var body: some Scene {

        WindowGroup {
            RootView()
                .environment(userSession)
                .modelContainer(for: TacticalAnalysis.self)
        }
    }
}
