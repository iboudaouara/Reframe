import Testing
import Foundation
@testable import Reframe

struct ProfileTests {
    
    @Test("Changer d'avatar met à jour l'utilisateur immédiatement (Optimistic UI)")
    @MainActor
    func testAvatarUpdateLogic() async throws {
        
        let spy = SpyAuthService()
        let session = UserSession(authService: spy)
        
        try await Task.sleep(nanoseconds: 600_000_000)
        
        try await session.login(email: "test", password: "pwd")
        
        #expect(session.state.isLoggedIn, "L'utilisateur doit être connecté avant de tester l'avatar.")
        
        try await session.updateAvatar(.avatar5)
        
        #expect(session.user?.profileIcon == .avatar5, "L'icône locale doit être mise à jour immédiatement.")
        #expect(spy.updateProfileIconCalled == true, "La session aurait dû tenter d'appeler le serveur.")
        #expect(spy.lastIconSent == .avatar5, "La session a envoyé la mauvaise icône au serveur.")
    }
}
