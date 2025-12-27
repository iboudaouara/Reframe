//
//  SessionOptimizationTests.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-12-27.
//


import Testing
import Foundation
@testable import Reframe

struct SessionOptimizationTests {

    @Test("Ne doit PAS appeler le serveur si c'est une nouvelle installation (pas de flag local)")
    @MainActor
    func testNoServerCheckOnFreshInstall() async {
        // GIVEN (Mise en place)
        // 1. On nettoie UserDefaults pour simuler une "Installation Fraîche"
        UserDefaults.standard.removeObject(forKey: "hasCompletedLogin")
        
        // 2. On prépare notre Espion
        let spyService = SpyAuthService()
        
        // 3. On injecte l'espion dans la Session
        let session = Session(authService: spyService)

        // WHEN (Action)
        // On déclenche la vérification de session
        await session.checkSessionStatus()

        // THEN (Vérification)
        // Le moment de vérité : le compteur doit être à 0 !
        #expect(spyService.verifyTokenCallCount == 0, "L'application ne devrait pas avoir tenté de vérifier le token sur le serveur.")
        
        // Vérifier que l'état est bien resté 'unauthenticated'
        if case .unauthenticated = session.state {
            // Succès
        } else {
            Issue.record("La session devrait être non-authentifiée.")
        }
    }
}