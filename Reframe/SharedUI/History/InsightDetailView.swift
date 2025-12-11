import SwiftUI

struct InsightDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let insight: Insight

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Thought")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(insight.userThought)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Insight")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(insight.generatedInsight)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }

                    HStack {
                        Image(systemName: "clock")
                        Text(insight.timestamp, format: .dateTime.day().month().year().hour().minute())
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Insight Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InsightDetailView(insight: Insight(
        userThought: "I need to improve my SwiftUI skills",
        generatedInsight: "Practice building small SwiftUI components daily.",
        timestamp: Date()
    ))
}
