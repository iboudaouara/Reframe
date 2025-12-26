import SwiftUI
import SwiftData

@main
struct ReframeApp: App {
    @State private var session = Session()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                //.modelContainer(for: Insight.self)
                .modelContainer(for: TacticalSession.self)
        }
    }
}
