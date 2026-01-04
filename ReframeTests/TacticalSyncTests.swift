import Testing
import SwiftData
import Foundation
@testable import Reframe

@MainActor
struct TacticalSyncTests {
    
    @Test("Vérifier que la synchronisation envoie les analyses au serveur")
    func testTacticalSynchronization() async throws {
        // 1. GIVEN : Setup SwiftData en mémoire (propre à chaque test)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TacticalAnalysis.self, configurations: config)
        let context = container.mainContext
        
        // On utilise un Mock pour ne pas dépendre du réseau, 
        // ou AuthService.shared si tu veux tester le vrai serveur.
        let mockAuth = ReframeTests.MockAuthService()
        let session = Session(authService: mockAuth)
        
        // On simule une connexion pour avoir un token
        try await session.login(email: "test@sync.com", password: "password")
        
        // On crée une analyse tactique locale
        let analysis = TacticalAnalysis(
            situation: "Test de synchronisation",
            analysis: StrategicAnalysis(
                maneuver: Maneuver(id: 1, name: "Test", description: "Desc", powerScore: 50, emotionalImpact: "High"),
                recommendedMoves: []
            )
        )
        context.insert(analysis)
        try context.save()
        
        // Vérification initiale : elle doit être en attente
        #expect(analysis.syncStatus == "pending")
        #expect(analysis.serverId == nil)

        // 2. WHEN : On lance la synchronisation
        await session.synchronize(modelContext: context)

        // 3. THEN : On vérifie les changements
        // Si ton Mock/Serveur répond avec succès, le statut doit changer
        #expect(analysis.syncStatus == "synced")
        #expect(analysis.serverId != nil, "L'analyse devrait avoir reçu un ID du serveur")
    }
}