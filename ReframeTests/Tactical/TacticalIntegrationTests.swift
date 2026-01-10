//
//  TacticalIntegrationTests.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2026-01-03.
//


import Testing
import SwiftData
import Foundation
@testable import Reframe

@MainActor
struct TacticalIntegrationTests {

    @Test("Cycle complet de synchronisation : Upload et Récupération")
    func testFullTacticalSyncCycle() async throws {
        // 1. GIVEN : Un utilisateur réel connecté et une analyse locale
        let service = AuthService.shared
        let session = UserSession(authService: service)
        
        // Connexion réelle (assure-toi que ce compte existe)
        try await session.login(email: "test@reframe.com", password: "ton_password")
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TacticalAnalysis.self, configurations: config)
        let context = container.mainContext
        
        let localAnalysis = TacticalAnalysis(
            situation: "Test de synchro \(Date().timeIntervalSince1970)",
            analysis: StrategicAnalysis(
                maneuver: Maneuver(id: 1, name: "Test", description: "Desc", powerScore: 50, emotionalImpact: "High"),
                recommendedMoves: []
            )
        )
        context.insert(localAnalysis)
        try context.save()

        // 2. WHEN : Upload (Synchronisation montante)
        // On appelle ta méthode de Session qui boucle sur les analyses 'pending'
        await session.synchronize(modelContext: context)

        // 3. THEN : Vérifier que l'upload a fonctionné
        #expect(localAnalysis.syncStatus == "synced")
        #expect(localAnalysis.serverId != nil, "Le serveur aurait dû renvoyer un ID")
        
        let assignedId = localAnalysis.serverId

        // 4. ACTION : Download (Synchronisation descendante)
        // On simule une réinitialisation : on supprime l'analyse locale
        context.delete(localAnalysis)
        try context.save()
        #expect((try? context.fetch(FetchDescriptor<TacticalAnalysis>()))?.isEmpty == true)

        // On demande à TacticalService de récupérer l'historique
        let history = try await TacticalService.shared.fetchHistory(token: session.user?.token ?? "")
        
        // 5. VERIFICATION : L'analyse est-elle revenue du serveur ?
        let foundInHistory = history.contains { $0.situation.contains(localAnalysis.situation) }
        #expect(foundInHistory == true, "L'analyse devrait être présente dans l'historique serveur")
    }
}
