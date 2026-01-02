import SwiftUI
import SwiftData

@Observable
final class UserSession {

    private let authService: AuthServiceProtocol

    private(set) var state: SessionState = .loading

    var user: User? {
        guard case .authenticated(let u) = state else { return nil }
        return u
    }

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        startSessionCheck()
    }

    private func startSessionCheck() {
        Task {
            await checkSessionStatus()
        }
    }

    @MainActor
    private func checkSessionStatus() async {
        state = .loading

        try? await Task.sleep(nanoseconds: 500_000_000)

        do {
            let user = try await authService.loadUserFromSession()
            self.state = .authenticated(user)
            print("✅ Session restaurée : \(user.id)")
        } catch {
            print("ℹ️ Pas de session active : \(error)")
            self.state = .unauthenticated
        }
    }

    @MainActor
    private func completeAuthentication(with user: User) {
        print("🕵️ EXAMEN DU TOKEN AVANT SAUVEGARDE :")
        print("👤 User ID: \(user.id)")
        print("🔑 Token reçu: '\(user.token)'") // Vérifie s'il est vide !

        if user.token.isEmpty {
            print("🛑 ALERTE : Le token est vide ! Le backend n'a pas renvoyé de token.")
        } else {
            KeychainManager.shared.saveToken(user.token)
            print("💾 Token sauvegardé dans le Keychain.")

            // TEST IMMÉDIAT DE RELECTURE
            let check = KeychainManager.shared.getToken()
            print("🔍 Vérification immédiate Keychain : \(check ?? "NIL")")
        }

        self.state = .authenticated(user)
    }

    @MainActor
    func synchronize(modelContext: ModelContext) async {
        guard case .authenticated(let currentUser) = state else {
            print("⚠️ Synchronisation annulée : Pas d'utilisateur connecté")
            return
        }

        print("🔄 Sync pour user: \(currentUser.id)")

        await TacticalService.shared.synchronize(modelContext: modelContext, token: currentUser.token)
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

    @MainActor
    func continueAsGuest(modelContext: ModelContext) {
        state = .guest
    }

    @MainActor
    func login(email: String, password: String) async throws {
        state = .loading
        do {
            let user = try await authService.login(email: email, password: password)
            completeAuthentication(with: user)
        } catch {
            state = .unauthenticated
            throw error
        }
    }

    @MainActor
    func signup(firstName: String, lastName: String, email: String, password: String) async throws {
        state = .loading

        do {
            let user = try await AuthService.shared.signup(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            completeAuthentication(with: user)
        } catch {
            state = .unauthenticated
            throw error
        }
    }

    @MainActor
    func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws {
        state = .loading

        let cachedEmail = KeychainManager.shared.getEmailForAppleID(userIdentifier)
        guard let definitiveEmail = email ?? cachedEmail else {
            state = .unauthenticated
            throw SessionError.missingToken
        }

        let user = try await AuthService.shared.loginWithApple(
            userIdentifier: userIdentifier,
            email: definitiveEmail,
            firstName: firstName,
            lastName: lastName
        )

        completeAuthentication(with: user)
        KeychainManager.shared.saveEmailForAppleID(definitiveEmail, for: userIdentifier)
    }

    @MainActor
    func logout() {
        AuthService.shared.logout()
        state = .unauthenticated
    }

    @MainActor
    func deleteAccount(modelContext: ModelContext) async throws {
        guard case .authenticated(let currentUser) = state else {
            throw SessionError.missingToken
        }

        _ = try await AuthService.shared.deleteAccount(token: currentUser.token)

        try modelContext.delete(model: TacticalSession.self)

        logout()
    }

    // Dans Session.swift
    @MainActor
    func updateAvatar(_ icon: ProfileIcon) async throws {
        guard case .authenticated(var currentUser) = state else { return }

        // Mise à jour optimiste immédiate
        currentUser.profileIcon = icon
        state = .authenticated(currentUser)

        // TODO: Appel réseau ici pour sauvegarder (ex: authService.updateProfile(...))
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

enum SessionState {

    case loading
    case unauthenticated
    case authenticated(User)
    case guest

    var isLoggedIn: Bool {
        if case .authenticated = self { true } else { false }
    }

    var isGuest: Bool {
        if case .guest = self { true } else { false }
    }

    var isLoading: Bool {
        if case .loading = self { true } else { false }
    }

}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String?
    let lastName: String?
    let token: String

    var profileIcon: ProfileIcon = .avatar1

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "firstname"
        case lastName = "lastname"
        case token
    }

    var fullName: String {
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName

        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: components).trimmingCharacters(in: .whitespaces)
    }
}
