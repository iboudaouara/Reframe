import SwiftUI
import Foundation

final class TacticalService {
    static let shared = TacticalService()
    private let server = ReframeServer.shared

    private init() {}

    func analyze(situation: String) async throws -> StrategicAnalysis {

        // 👇 AJOUTE CES LOGS ICI 👇
                print("-------------------------------------------------")
                print("🚀 [TACTICAL] Tentative d'appel")
                print("📍 URL Base: \(AppURL.tacticalURL)")
                print("📍 Endpoint: analyze")
                print("🔗 URL Complète (Théorique): \(AppURL.tacticalURL)/analyze")
                print("📦 Données envoyées: \(situation)")
                print("-------------------------------------------------")
        
        return try await server
            .request(
                endpoint: "analyze",
                method: "POST",
                body: ["input": situation],
                urlBase: AppURL.tacticalURL
            )
    }

    func fetchPlaybook(for maneuverId: Int) async throws -> [CounterMove] {
        return try await server.request(
            endpoint: "maneuvers/\(maneuverId)/moves",
            method: "GET", urlBase: AppURL.tacticalURL)

    }

    func reportOutcome(moveId: Int, wasSucessful: Bool) async throws {
        let body = ["success": wasSucessful]
        let _ : EmptyResponse = try await server.request(
            endpoint: "moves/\(moveId)/vote",
            method: "POST",
            body: body,
            urlBase: AppURL.tacticalURL
        )
    }

    struct EmptyResponse: Decodable {}
}

import SwiftData

extension TacticalService {
/*
    // Structure pour mapper la réponse du serveur (à adapter selon ton API réelle)
    struct RemoteTacticalSession: Decodable {
        let id: Int
        let situation: String
        let created_at: Date
        // Ajoute ici les autres champs que ton serveur renvoie (maneuver, etc.)

        // Convertisseur Remote -> Local
        func toLocal() -> TacticalAnalysis {
            // Ici, tu devras reconstruire l'objet complet avec les données du serveur
            // Pour l'exemple, je mets des valeurs par défaut si manquantes
            return TacticalAnalysis(
                situation: situation,
                analysis: StrategicAnalysis(
                    maneuver: Maneuver(id: 0, name: "Inconnu", description: "", powerScore: 0, emotionalImpact: ""),
                    recommendedMoves: []
                )
            )
        }
    }*/

    @MainActor
    func synchronize(modelContext: ModelContext, token: String) async {
        print("🛡️ [TACTICAL] Début synchro...")

        // 1. Envoyer les sessions locales non-synchronisées
        await uploadPendingSessions(modelContext: modelContext, token: token)

        // 2. Récupérer l'historique du serveur
        await downloadRemoteSessions(modelContext: modelContext, token: token)

        try? modelContext.save()
        print("🛡️ [TACTICAL] Synchro terminée.")
    }

    @MainActor
    private func uploadPendingSessions(modelContext: ModelContext, token: String) async {
        // Récupérer tout ce qui est "pending" ou "error"
        let descriptor = FetchDescriptor<TacticalAnalysis>(
            predicate: #Predicate { $0.syncStatus == "pending" || $0.syncStatus == "error" }
        )

        guard let pendingSessions = try? modelContext.fetch(descriptor), !pendingSessions.isEmpty else { return }

        // Remplacer le bloc existant par :
        for session in pendingSessions {
            do {
                // APPEL AU SERVEUR
                let remoteId = try await server.saveTacticalSession(session, token: token)

                session.serverId = remoteId
                session.syncStatus = "synced"
                print("✅ Session locale uploadée: \(session.id) -> Server ID: \(remoteId)")
            } catch {
                print("❌ Échec upload session \(session.id): \(error)")
                session.syncStatus = "error"
            }
        }
    }

    @MainActor
    private func downloadRemoteSessions(modelContext: ModelContext, token: String) async {
        // Remplacer le bloc existant par :
        do {
            // APPEL AU SERVEUR
            let remoteSessions = try await server.fetchTacticalHistory(token: token)

            let localDescriptor = FetchDescriptor<TacticalAnalysis>()
            let localSessions = try modelContext.fetch(localDescriptor)
            let localServerIds = Set(localSessions.compactMap { $0.serverId })

            for remote in remoteSessions {
                // Si on ne l'a pas déjà en local
                if !localServerIds.contains(remote.id) {
                    let newSession = remote.toLocal()
                    newSession.serverId = remote.id
                    newSession.syncStatus = "synced"
                    modelContext.insert(newSession)
                    print("📥 Nouvelle session importée du serveur: \(remote.id)")
                }
            }
        } catch {
            print("❌ Erreur téléchargement historique: \(error)")
        }
    }

    
}

extension TacticalService {
    struct RemoteTacticalSession: Decodable {
        let id: Int
        let situation: String
        let maneuver_name: String
        let maneuver_description: String
        let power_score: Int
        let emotional_impact: String
        let created_at: Date

        func toLocal() -> TacticalAnalysis {
            // On crée un objet "vide" d'analyse pour l'init, puis on remplit
            let analysis = StrategicAnalysis(
                maneuver: Maneuver(id: 0, name: maneuver_name, description: maneuver_description, powerScore: power_score, emotionalImpact: emotional_impact),
                recommendedMoves: []
            )

            let local = TacticalAnalysis(situation: situation, analysis: analysis)
            local.serverId = id
            local.syncStatus = "synced"
            local.timestamp = created_at
            return local
        }
    }
}
