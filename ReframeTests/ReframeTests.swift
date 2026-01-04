import Testing
import Foundation
@testable import Reframe

@MainActor
struct ReframeTests {

    init() {
        KeychainManager.shared.deleteToken()
    }

    @Test("Test du Login succès avec mise à jour de la Session")
    @MainActor
    func testLoginSuccess() async throws {
        let mockService = MockAuthService()
        let session = Session(authService: mockService)

        #expect(session.state.isLoggedIn == false, "La session ne devrait pas être connectée au départ")

        try await session.login(email: "test@mail.com", password: "Password123$$")

        #expect(session.state.isLoggedIn == true, "La session devrait être passée à l'état connecté")

        #expect(session.user?.firstName == "Test")
        #expect(session.user?.token == "fake-jwt-token-123")

        if case .authenticated(let user) = session.state {
            #expect(user.id == 999)
        } else {
            Issue.record("L'état de la session devrait être .authenticated")
        }
    }

    @Test("Test du Login échoué (mauvais mot de passe)")
    @MainActor
    func testLoginFailure() async {
        let mockService = MockAuthService()
        let session = Session(authService: mockService)

        // On s'attend à ce que ça lance une erreur
        await #expect(throws: Error.self) {
            try await session.login(email: "test@reframe.com", password: "error")
        }

        #expect(session.state.isLoggedIn == false, "La session devrait rester déconnectée après une erreur")
    }

    @Test("Vérifier qu'un utilisateur peut s'inscrire avec succès")
    @MainActor
    func testSignupFlowSuccess() async throws {

        let mock = MockAuthService()
        let session = Session(authService: mock)

        #expect(session.state.isLoggedIn == false)

        try await session.signup(
            firstName: "Ibrahim",
            lastName: "Bou",
            email: "nouveau@reframe.com",
            password: "Password123!"
        )

        #expect(session.state.isLoggedIn == true)

        #expect(session.user?.firstName == "Ibrahim")
        #expect(session.user?.email == "nouveau@reframe.com")

        #expect(session.user?.token == "signup-token")
    }

}

//#warning("TODO: Simuler une panne serveur pour vérifier le timeout des requêtes")

