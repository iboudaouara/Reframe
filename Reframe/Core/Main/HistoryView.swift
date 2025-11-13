import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Insight.timestamp, order: .reverse) private var insights: [Insight]
    @State private var selectedInsight: Insight?

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

    private func deleteInsights(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(insights[index])
            }
        }
    }
}





#Preview {
    HistoryView()
        .modelContainer(for: Insight.self, inMemory: true)
}
