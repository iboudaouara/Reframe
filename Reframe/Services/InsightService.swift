import SwiftData
import SwiftUI

final class InsightService {
    static let shared = InsightService()
    private let server = ReframeServer.shared

    private init() {}

    @MainActor
    func uploadInsight(insight: Insight, token: String) async throws {
        let remoteInsight = try await server.saveInsight(
            thought: insight.userThought,
            insight: insight.generatedInsight,
            token: token
        )

        insight.serverId = remoteInsight.id
        insight.syncStatus = .synced
    }

    @MainActor
    func synchronize(modelContext: ModelContext, token: String) async throws {
        print("🚀 Début de la synchronisation des Insights...")

        try await uploadPendingInsights(modelContext: modelContext, token: token)

        try await downloadRemoteInsights(modelContext: modelContext, token: token)

        try modelContext.save()
        print("✅ Synchronisation des Insights terminée.")
    }

    @MainActor
    private func uploadPendingInsights(modelContext: ModelContext, token: String) async throws {

        let allInsightsFetch = FetchDescriptor<Insight>()
        let allInsights = try modelContext.fetch(allInsightsFetch)

        let pendingInsights = allInsights.filter { $0.syncStatus == .pending || $0.syncStatus == .error }

        guard !pendingInsights.isEmpty else { return }

        for insight in pendingInsights {
            do {
                try await uploadInsight(insight: insight, token: token)
            } catch {
                print("❌ Échec de l'upload de l'insight \(insight.id): \(error.localizedDescription)")
                insight.syncStatus = .error
            }
        }

        try modelContext.save()
    }

    @MainActor
    private func downloadRemoteInsights(modelContext: ModelContext, token: String) async throws {
        let remoteInsights = try await server.fetchUserInsights(token: token)

        let localInsights = try modelContext.fetch(FetchDescriptor<Insight>())
        let localServerIds = Set(localInsights.compactMap { $0.serverId })

        for remote in remoteInsights {
            if !localServerIds.contains(remote.id) {
                let newLocalInsight = remote.localInsight
                modelContext.insert(newLocalInsight)
                print("📥 Nouvel insight du serveur ajouté: \(remote.id)")
            }
        }
    }

    func deleteInsight(id: Int, token: String) async throws {
        _ = try await server.deleteInsight(id: id, token: token)
    }
}
