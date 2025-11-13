import SwiftUI
import SwiftData

final class AccountDeletionService {
    static let shared = AccountDeletionService()

    func deleteAccount(session: UserSession, modelContext: ModelContext) {
        Task {
            session.logout()
            KeychainItem.deleteUserIdentifier()

            clearAllInsights(context: modelContext)

            print("✅ Account and all local data deleted")
        }
    }

    private func clearAllInsights(context: ModelContext) {
        do {
            let fetchRequest = FetchDescriptor<Insight>()

            let allInsights = try context.fetch(fetchRequest)

            for insight in allInsights {
                context.delete(insight)
            }


            try context.save()
            print("✅ All local insights deleted")
        } catch {
            print("❌ Failed to delete insights:", error)
        }
    }
}
