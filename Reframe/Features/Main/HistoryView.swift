import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TacticalSession.timestamp, order: .reverse) private var history: [TacticalSession]
    @State private var selectedSession: TacticalSession?
    @Environment(Session.self) private var session
    
    var body: some View {
        Group {
            if history.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(history) { session in
                        TacticalRow(session: session)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSession = session
                            }
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteSessions)
                }
            }
        }
        .navigationTitle("Historique")
        .sheet(item: $selectedSession) { session in
            NavigationStack {
                TacticalDetailView(session: session)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fermer") { selectedSession = nil }
                        }
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("Aucune analyse")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Utilisez le Radar Social pour décoder votre première interaction.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(history[index])
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: TacticalSession.self, inMemory: true)
}
