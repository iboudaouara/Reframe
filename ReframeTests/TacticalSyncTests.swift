//
//  TacticalSyncTests.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2026-01-03.
//


import Testing
import SwiftData
import Foundation
@testable import Reframe

@MainActor
struct TacticalSyncTests {
    
    @Test("Vérifier que la synchronisation envoie les analyses au serveur")
    func testTacticalSynchronization() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TacticalAnalysis.self, configurations: config)
        let context = container.mainContext
        
        let mockAuth = MockAuthService()
        let session = Session(authService: mockAuth)
        
        try await session.login(email: "test@sync.com", password: "password")
        
        let analysis = TacticalAnalysis(
            situation: "Test de synchronisation",
            analysis: StrategicAnalysis(
                maneuver: Maneuver(id: 1, name: "Test", description: "Desc", powerScore: 50, emotionalImpact: "High"),
                recommendedMoves: []
            )
        )
        context.insert(analysis)
        try context.save()
        
        #expect(analysis.syncStatus == "pending")
        #expect(analysis.serverId == nil)

        await session.synchronize(modelContext: context)

        #expect(analysis.syncStatus == "synced")
        #expect(analysis.serverId != nil, "L'analyse devrait avoir reçu un ID du serveur")
    }
}
