import Foundation
import SwiftUI
import Combine

@Observable @MainActor
final class InsightController {
    var generatedInsight: String?
    var isLoading: Bool = false
    var errorMessage: String?
    private let server = ReframeServer()

    func generateInsight(from input: String) {
        guard !input.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await server.generateInsight(from: input)

                if let reply = response.reply {
                    self.generatedInsight = reply
                } else if let error = response.error {
                    self.errorMessage = error
                }

            } catch {
                self.errorMessage = error.localizedDescription
            }

            self.isLoading = false
        }
    }
}

import Foundation
import SwiftData

@Model
final class Insight {
    @Attribute(.unique) private(set) var id: UUID = UUID()
    var userThought: String
    var generatedInsight: String
    var timestamp: Date

    init(
        userThought: String,
        generatedInsight: String,
        timestamp: Date = Date()
    ) {
        self.userThought = userThought
        self.generatedInsight = generatedInsight
        self.timestamp = timestamp
    }
}
