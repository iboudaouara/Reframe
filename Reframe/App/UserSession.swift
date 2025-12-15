import SwiftUI
import SwiftData

struct User: Codable {
    let id: Int
    let firstname: String?
    let lastname: String?
    let email: String
    let token: String

    var fullName: String {
        return [firstname, lastname]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

@Observable final class UserSession {
    var user: User?

    var isLoggedIn = false
    var isLoading = false

    var selectedAvatar: ProfileIcon = .avatar1
    var isPickerPresented: Bool = false

    private let authService = AuthService.shared
    private let insightService = InsightService.shared

    @MainActor
    private func completeAuthentication(for user: User) {
        self.user = user
        self.isLoggedIn = true
        KeychainManager.shared.saveToken(user.token)
    }
    
    @MainActor
    func synchronize(modelContext: ModelContext) async {

        guard isLoggedIn, let token = user?.token else {
            print("⚠️ synchronizeIfLoggedIn: pas de user ou token")

            return
        }
        print("🔄 synchronizeIfLoggedIn - user: \(user?.id ?? 0)")

        // Optionnel : nettoyer les insights locaux avant sync (utile lors d'un changement d'utilisateur)

        print("🧹 Nettoyage des insights locaux...")
        clearLocalInsights(modelContext: modelContext)
                
        try? await insightService.synchronize(modelContext: modelContext, token: token)
    }

    enum SessionError: LocalizedError {
        case missingToken

        var errorDescription: String? {
            switch self {
            case .missingToken:
                return "Authentication token is missing. Please sign in again."
            }
        }
    }

    init() {
        self.isLoading = true
        Task {
            await checkSessionStatus()
        }
    }

    func triggerEditAvatar() {
        isPickerPresented = true
    }

    @MainActor
    func login(email: String, password: String) async throws {
        let user = try await AuthService.shared.login(email: email, password: password)
        completeAuthentication(for: user)
    }

    @MainActor
    func signup(firstName: String, lastName: String, email: String, password: String) async throws {
        let user = try await AuthService.shared.signup(firstName: firstName,
                                                       lastName: lastName, email: email, password: password)
        completeAuthentication(for: user)
    }

    @MainActor
    func loginWithApple(userIdentifier: String, email: String?, fullName: String?) async throws {
        let user = try await AuthService.shared.loginWithApple(
            userIdentifier: userIdentifier,
            email: email,
            fullName: fullName
        )
        completeAuthentication(for: user)
    }

    @MainActor
    func logout() {
        AuthService.shared.logout()
        self.user = nil
        self.isLoggedIn = false
    }

    @MainActor
    func checkSessionStatus() async {
        self.isLoading = true
        self.isLoggedIn = false

        defer {
            self.isLoading = false
        }

        let token = await Task.detached {
            return await KeychainManager.shared.getToken()
        }.value

        guard let validToken = token else {
            self.isLoggedIn = false
            print("Aucun jeton trouvé.")
            return
        }

        do {
            let user = try await authService.verifyTokenAndFetchUser(token: validToken)

            self.user = user
            self.isLoggedIn = true
            print("Session réactivée pour l'utilisateur \(user.id).")
        } catch {
            // ... (gestion de l'erreur) ...
        }
    }

    @MainActor
    func deleteAccount(modelContext: ModelContext) async throws {
        guard let token = user?.token else {
            throw SessionError.missingToken
        }

        _ = try await AuthService.shared.deleteAccount(token: token)

        try modelContext.delete(model: Insight.self)

        self.logout()
    }

    @MainActor
    private func clearLocalInsights(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Insight.self)
            print("✅ Insights locaux supprimés")
        } catch {
            print("❌ Erreur lors de la suppression des insights locaux:", error)
        }
    }

    func observeSessionExpiration() {
        NotificationCenter.default.addObserver(
            forName: .userSessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task(){
                await self?.logout()
            }
        }
    }
}

extension Notification.Name {
    static let userSessionExpired = Notification.Name("userSessionExpired")
}
