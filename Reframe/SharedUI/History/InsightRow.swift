import SwiftUI

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(insight.userThought)
                .font(.headline)
                .lineLimit(2)

            Text(insight.generatedInsight)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Text(insight.timestamp,
                 format: .dateTime.day().month().year().hour().minute())
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InsightRow(insight: Insight(
        userThought: "I need to improve my SwiftUI skills",
        generatedInsight: "Practice building small SwiftUI components daily.",
        timestamp: Date()
    ))
}
