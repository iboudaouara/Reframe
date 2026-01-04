import Testing
import SwiftData
import Foundation
@testable import Reframe

struct IntegrationTests {

    @Test("Vrai Login sur le serveur (Succès)", .tags(.integration))
    @MainActor
    func testRealLoginSuccess() async throws {

        let realEmail = "test@mail.com"
        let realPassword = "VraiPass123$"

        let service = AuthService.shared

        let user = try await service.login(email: realEmail, password: realPassword)

        #expect(user.email == realEmail)
        #expect(!user.token.isEmpty, "Le serveur doit renvoyer un token valide")
        
        #expect(user.token.contains("."), "Le token devrait être au format JWT")
    }

    @Test("Vrai Login sur le serveur (Échec)", .tags(.integration))
    @MainActor
    func testRealLoginFailure() async {
        let service = AuthService.shared
        
        await #expect(throws: Error.self) {
            try await service.login(email: "ibrahim@reframe.com", password: "MAUVAIS_PASSWORD")
        }
    }

    @Test("Le serveur doit refuser un mauvais mot de passe (401/400)")
    @MainActor
    func testServerErrorHandling() async {
        let service = AuthService.shared

        await #expect(throws: Error.self) {
            // Le serveur devrait renvoyer une erreur que ReframeServer décode
            try await service.login(email: "inconnu@reframe.com", password: "wrong_password")
        }
    }

    @Test("Vrai Signup sur le serveur (Succès)", .tags(.integration))
    @MainActor
    func testRealServerSignupSuccess() async throws {
        let service = AuthService.shared

        // Utilisez un email unique (ex: timestamp) pour éviter l'erreur "déjà existant"
        let uniqueEmail = "test_\(Int(Date().timeIntervalSince1970))@mail.com"

        // 1. Appel réel au serveur
        let user = try await service.signup(
            firstName: "Test",
            lastName: "Integration",
            email: uniqueEmail,
            password: "VraiPassword123!"
        )

        // 2. Vérification de la réponse serveur
        #expect(user.email == uniqueEmail)
        #expect(!user.token.isEmpty, "Le serveur doit générer un token pour le nouvel utilisateur")
    }

    @Test("Le serveur doit refuser un email déjà utilisé", .tags(.integration))
    @MainActor
    func testRealServerSignupDuplicateError() async {
        let service = AuthService.shared
        let existingEmail = "test@mail.com" // Un email que vous savez déjà présent en base

        // On s'attend à ce que le serveur lève une erreur
        await #expect(throws: Error.self) {
            try await service.signup(
                firstName: "Ibrahim",
                lastName: "B",
                email: existingEmail,
                password: "Password123!"
            )
        }
    }

    @Test("Vérifier que la suppression de compte nettoie tout")
    @MainActor
    func testDeleteAccountFlow() async throws {
        // 1. GIVEN : Un utilisateur est déjà connecté avec un Mock
        let mock = AuthService.shared
        let session = Session(authService: mock)

        // On simule une connexion réussie
        try await session.login(email: "test@mail.com", password: "VraiPass123$")
        #expect(session.state.isLoggedIn == true)

        // Configuration d'un SwiftData en mémoire pour le test
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TacticalAnalysis.self, configurations: config)
        let context = container.mainContext

        // 2. WHEN : On déclenche la suppression
        try await session.deleteAccount(modelContext: context)

        // 3. THEN : Tout doit être remis à zéro
        #expect(session.state.isLoggedIn == false, "L'état doit redevenir unauthenticated")
        #expect(session.user == nil, "L'utilisateur doit être supprimé de la mémoire")

        // Vérification du Keychain (le token doit avoir disparu)
        #expect(KeychainManager.shared.getToken() == nil)
    }
}

extension Tag {
    @Tag static var integration: Self
}
