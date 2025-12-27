import Testing
import Foundation
@testable import Reframe

struct ReframeTests {

    // 1. On définit un "Faux Service" qui respecte votre protocole AuthServiceProtocol
    // Il ne fait aucun appel réseau réel.
    struct MockAuthService: AuthServiceProtocol {

        func login(email: String, password: String) async throws -> User {
            // Simulation : Si le mot de passe est "error", on simule un échec
            if password == "error" {
                throw URLError(.userAuthenticationRequired)
            }

            // Sinon, on retourne un utilisateur fictif immédiatement
            return User(
                id: 999,
                email: email,
                firstName: "Test",
                lastName: "User",
                token: "fake-jwt-token-123"
            )
        }

        // --- Méthodes obligatoires du protocole (implémentation vide ou par défaut) ---
        func logout() { }

        func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User {
            return User(id: 999, email: email, firstName: firstName, lastName: lastName, token: "signup-token")
        }

        func deleteAccount(token: String) async throws -> DeleteAccountResponse {
            return DeleteAccountResponse(message: "Account deleted")
        }

        func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User {
            return User(id: 888, email: email ?? "apple@test.com", firstName: firstName, lastName: lastName, token: "apple-token")
        }

        func verifyTokenAndFetchUser(token: String) async throws -> User {
            return User(id: 999, email: "verified@test.com", firstName: "Verified", lastName: "User", token: token)
        }
    }

    // 2. Le Test de Connexion (Happy Path)
    @Test("Test du Login succès avec mise à jour de la Session")
    @MainActor // Important car Session est @Observable (MainActor)
    func testLoginSuccess() async throws {
        // GIVEN (Mise en place)
        let mockService = MockAuthService()
        let session = Session(authService: mockService) // On injecte notre faux service

        // Vérification de l'état initial
        #expect(session.isLoggedIn == false, "La session ne devrait pas être connectée au départ")

        // WHEN (Action)
        try await session.login(email: "test@mail.com", password: "Password123$$")

        // THEN (Vérification)
        #expect(session.isLoggedIn == true, "La session devrait être passée à l'état connecté")

        // On vérifie que les données de l'utilisateur fictif sont bien là
        #expect(session.user?.firstName == "Test")
        #expect(session.user?.token == "fake-jwt-token-123")

        // Vérification précise de l'enum state
        if case .authenticated(let user) = session.state {
            #expect(user.id == 999)
        } else {
            Issue.record("L'état de la session devrait être .authenticated")
        }
    }

    // 3. (Optionnel) Test de l'échec
    @Test("Test du Login échoué (mauvais mot de passe)")
    @MainActor
    func testLoginFailure() async {
        let mockService = MockAuthService()
        let session = Session(authService: mockService)

        // On s'attend à ce que ça lance une erreur
        await #expect(throws: Error.self) {
            try await session.login(email: "test@reframe.com", password: "error")
        }

        #expect(session.isLoggedIn == false, "La session devrait rester déconnectée après une erreur")
    }

}
