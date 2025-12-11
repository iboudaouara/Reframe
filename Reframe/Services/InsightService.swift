import SwiftData
import SwiftUI

final class InsightService {
    static let shared = InsightService()
    private let server = ReframeServer.shared

    var generatedInsight: String?
    var isLoading: Bool = false
    var errorMessage: String?
    
    @MainActor
    func generateInsight(from thought: String) async throws -> String {
        guard !thought.isEmpty else { return ""}

        isLoading = true
        //errorMessage = nil

        Task {
            do {
                do {
                    let response = try await server.generateInsight(from: thought)
                    if let reply = response.reply {
                        self.generatedInsight = reply

                    } else if let error = response.error {
                        self.errorMessage = error
                    } else {
                        self.errorMessage = "Server returned an invalid response."
                    }
                }
            }
        }
        let response: InsightResponse = try await server.generateInsight(from: thought)
/*
        if let reply = response.reply {
            self.generatedInsight = reply
            return reply
        } else if let error = response.error {
            throw InsightError.generationFailed(error)
        } else {
            throw InsightError.invalidResponse
        }*/
        return "";
    }
    enum InsightError: LocalizedError {
        case generationFailed(String)
        case invalidResponse
        case syncFailed

        var errorDescription: String? {
            switch self {
            case .generationFailed(let msg): return msg
            case .invalidResponse: return "Server returned invalid response"
            case .syncFailed: return "Failed to sync with server"
            }
        }
    }
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
extension InsightService {
    @MainActor
    func retryFailedSyncs(modelContext: ModelContext, token: String) async {
        let errorStatus = SyncStatus.error
        let descriptor = FetchDescriptor<Insight>(
            predicate: #Predicate { $0.syncStatus == errorStatus }
        )

        let errorInsights = try? modelContext.fetch(descriptor)

        guard let errorInsights = errorInsights, !errorInsights.isEmpty else { return }

        for insight in errorInsights {
            do {
                try await uploadInsight(insight: insight, token: token)
                print("✅ Retry successful for insight \(insight.id)")
            } catch {
                print("❌ Retry failed for insight \(insight.id): \(error)")
            }
        }
    }
}
