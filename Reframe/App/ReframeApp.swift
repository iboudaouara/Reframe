import SwiftUI
import SwiftData

@main
struct ReframeApp: App {
    @State private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .modelContainer(for: TacticalSession.self)
        }
    }
}

#warning("TODO: Simuler une panne serveur pour vérifier le timeout des requêtes")
