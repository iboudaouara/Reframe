import SwiftUI
import SwiftData

/*
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
                do {
                    let response = try await server.generateInsight(from: input)
                    
                    if let reply = response.reply {
                        self.generatedInsight = reply
                    } else if let error = response.error {
                        self.errorMessage = error
                    } else {
                        self.errorMessage = "Server returned an invalid response."
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
                self.isLoading = false
            }
        }
    }
}
*/

enum SyncStatus: String, Codable {
    case pending
    case synced
    case error
}

@Model
final class Insight {
    @Attribute(.unique) private(set) var id: UUID = UUID()
    
    var serverId: Int?
    var userThought: String
    var generatedInsight: String
    var timestamp: Date
    var syncStatus: SyncStatus
    
    init(
        userThought: String,
        generatedInsight: String,
        timestamp: Date = Date(),
        serverId: Int? = nil,
        syncStatus: SyncStatus = .pending
    ) {
        self.userThought = userThought
        self.generatedInsight = generatedInsight
        self.timestamp = timestamp
        self.serverId = serverId
        self.syncStatus = syncStatus
    }
}

