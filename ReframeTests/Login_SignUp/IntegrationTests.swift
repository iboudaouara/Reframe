import Testing
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
}

extension Tag {
    @Tag static var integration: Self
}
