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
