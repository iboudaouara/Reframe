//
//  ProfileTests.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-12-27.
//
/*

import Testing
import Foundation
@testable import Reframe

struct ProfileTests {

    @Test("Changer d'avatar met à jour l'utilisateur immédiatement (Optimistic UI)")
        @MainActor
        func testAvatarUpdateLogic() async throws {
            // GIVEN
            let spy = SpyAuthService()
            let session = Session(authService: spy)

            // --- FIX : On attend que le 'checkSessionStatus' du init se termine ---
            // On attend 0.6s car le Session.swift attend 0.5s
            try await Task.sleep(nanoseconds: 600_000_000)

            // Maintenant que l'état est stabilisé (probablement unauthenticated), on se connecte pour de vrai.
            try await session.login(email: "test", password: "pwd")

            // Vérification que le login a bien tenu
            #expect(session.isLoggedIn, "L'utilisateur doit être connecté avant de tester l'avatar.")

            // WHEN
            try await session.updateAvatar(.avatar5)

            // THEN
            #expect(session.user?.profileIcon == .avatar5, "L'icône locale doit être mise à jour immédiatement.")
            #expect(spy.updateProfileIconCalled == true, "La session aurait dû tenter d'appeler le serveur.")
            #expect(spy.lastIconSent == .avatar5, "La session a envoyé la mauvaise icône au serveur.")
        }
}
*/
