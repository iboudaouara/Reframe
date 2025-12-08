import SwiftUI
import SwiftData

struct User: Decodable {
    let id: String
    let name: String
    let email: String
    let token: String
}

@Observable final class UserSession {
    var user: User?
    var isLoggedIn = false
    var isLoading = false
    var selectedAvatar: ProfileIcon = .avatar1
    var isPickerPresented: Bool = false
    private let authService = AuthService.shared

    // A custom error enum for session-related failures
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
    func signup(name: String, email: String, password: String) async throws {
        let user = try await AuthService.shared.signup(name: name, email: email, password: password)
        completeAuthentication(for: user)
    }

    @MainActor
    func loginWithApple(userIdentifier: String, email: String?, fullName: String?) async throws {
        let user = try await AuthService.shared.loginWithApple(userIdentifier: userIdentifier, email: email, fullName: fullName)
        completeAuthentication(for: user)
    }

    @MainActor
    func logout() {
        AuthService.shared.logout()
        self.user = nil
        self.isLoggedIn = false
    }

    // Fichier: UserSession.swift

    @MainActor
    func checkSessionStatus() async {
        self.isLoading = true
        self.isLoggedIn = false

        defer {
            self.isLoading = false
        }

        // 🎯 CORRECTION: Utilisation de Task.detached pour exécuter la méthode synchrone
        // de Keychain en arrière-plan, rendant l'appel conforme au contexte async.

        let token = await Task.detached {
                // Exécute la méthode synchrone sur un thread non-bloquant
            return await KeychainManager.shared.getToken()
            }.value

        guard let validToken = token else {
            self.isLoggedIn = false
            print("Aucun jeton trouvé.")
            return
        }

        do {
            // Utilise le token validé
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

        // 1. Delete account on the server
        _ = try await AuthService.shared.deleteAccount(token: token)

        // 2. Delete all local data
        try modelContext.delete(model: Insight.self)

        // 3. Log out locally
        self.logout()
    }

    // Private helper to handle the final steps of authentication
    @MainActor
    private func completeAuthentication(for user: User) {
        self.user = user
        self.isLoggedIn = true
        KeychainManager.shared.saveToken(user.token)
    }
}
