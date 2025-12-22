import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Insight.timestamp, order: .reverse) private var insights: [Insight]
    @State private var selectedInsight: Insight?
    @Environment(Session.self) var session
    
    var body: some View {

            Group {
                if insights.isEmpty {
                    emptyStateView
                } else {
                    insightsList
                }
            }
            .navigationTitle("My Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $selectedInsight) { insight in
                InsightDetailView(insight: insight)
            }
        
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("No insights yet")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Generate your first insight to see it here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var insightsList: some View {
        List {
            ForEach(insights) { insight in
                InsightRow(insight: insight)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedInsight = insight
                    }
            }
            .onDelete(perform: deleteInsights)
        }
    }

    // Fichier: HistoryView.swift (dans la struct HistoryView)


        private func deleteInsights(offsets: IndexSet) {
            guard let token = session.user?.token else {
                print("Token manquant. Suppression locale seulement.")
                deleteLocally(offsets: offsets)
                return
            }

            Task {
                for index in offsets {
                    let insight = insights[index]

                    // 1. Tente de supprimer sur le serveur si un serverId est présent
                    if let serverId = insight.serverId {
                        do {
                            try await InsightService.shared.deleteInsight(id: serverId, token: token)
                            print("✅ Insight \(serverId) supprimé du serveur.")
                        } catch {
                            print("❌ Échec de la suppression sur le serveur pour l'insight \(serverId): \(error.localizedDescription)")
                            // Si la suppression échoue, nous supprimons localement de toute façon,
                            // mais l'insight pourrait réapparaître à la prochaine synchro si le serveur n'est pas cohérent.
                        }
                    }

                    // 2. Suppression locale
                    modelContext.delete(insight)
                }
                try? modelContext.save()
            }
        }

        private func deleteLocally(offsets: IndexSet) {
            withAnimation {
                for index in offsets {
                    modelContext.delete(insights[index])
                }
            }
            try? modelContext.save()
        }
    // ...
}





#Preview {
    HistoryView()
        .modelContainer(for: Insight.self, inMemory: true)
}
