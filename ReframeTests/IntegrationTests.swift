//
//  IntegrationTests.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-12-26.
//


import Testing
import Foundation
@testable import Reframe

struct IntegrationTests {

    // On utilise un tag pour pouvoir filtrer ces tests lents
    @Test("Vrai Login sur le serveur (Succès)", .tags(.integration))
    @MainActor
    func testRealLoginSuccess() async throws {
        // GIVEN
        // Utilisez un compte DE TEST qui existe vraiment dans votre base de données
        let realEmail = "test@mail.com" // Assurez-vous que ce compte existe !
        let realPassword = "VraiPass123$"     // Et que le mot de passe est bon

        let service = AuthService.shared // On utilise le VRAI service cette fois

        // WHEN
        let user = try await service.login(email: realEmail, password: realPassword)

        // THEN
        #expect(user.email == realEmail)
        #expect(!user.token.isEmpty, "Le serveur doit renvoyer un token valide")
        
        // Optionnel : Vérifier que le token est bien un JWT (contient des points)
        #expect(user.token.contains("."), "Le token devrait être au format JWT")
    }

    @Test("Vrai Login sur le serveur (Échec)", .tags(.integration))
    @MainActor
    func testRealLoginFailure() async {
        // GIVEN
        let service = AuthService.shared
        
        // WHEN & THEN
        // On essaie avec un mot de passe bidon
        await #expect(throws: Error.self) {
            try await service.login(email: "ibrahim@reframe.com", password: "MAUVAIS_PASSWORD")
        }
    }
}

// Déclaration du tag personnalisé
extension Tag {
    @Tag static var integration: Self
}
