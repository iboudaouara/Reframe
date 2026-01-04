import SwiftUI
import SwiftData

@Observable
final class Session {

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

    private func startSessionCheck() {
        Task {
            await checkSessionStatus()
        }
    }

    @MainActor
    func restorePreviousSession() async {
        // Le chargement devient un état transitoire géré par la vue ou un flag local
        do {
            let user = try await authService.loadUserFromSession()
            self.state = .authenticated(user) // Utilisation de votre idée de session fusionnée
        } catch {
            self.state = .unauthenticated
        }
    }

    @MainActor
    func checkSessionStatus() async {
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

    @MainActor
    func continueAsGuest(modelContext: ModelContext) {
        state = .guest
    }



    @MainActor
    func signup(firstName: String, lastName: String, email: String, password: String) async throws {
        state = .loading

        do {
            let user = try await authService.signup(
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
    func loginWithApple(data: AppleAuthData) async throws {
        state = .loading

        do {
            let cachedEmail = KeychainManager.shared.getEmailForAppleID(data.userIdentifier)
            guard let definitiveEmail = data.email ?? cachedEmail else {
                throw SessionError.missingToken
            }

            let user = try await authService.loginWithApple(data: data, definitiveEmail: definitiveEmail)

            completeAuthentication(with: user)
            KeychainManager.shared.saveEmailForAppleID(definitiveEmail, for: data.userIdentifier)

        } catch {
            // 2. IMPORTANT : Si ça plante, on enlève le chargement !
            print("❌ Erreur Login Apple : \(error)")
            state = .unauthenticated
            throw error // On relance l'erreur pour que le bouton puisse l'afficher si besoin
        }
    }

    @MainActor
    func logout() {
        authService.logout()
        state = .unauthenticated
    }

    @MainActor
    func deleteAccount(modelContext: ModelContext) async throws {
        guard case .authenticated(let currentUser) = state else {
            throw SessionError.missingToken
        }

        _ = try await authService.deleteAccount(token: currentUser.token)

        try modelContext.delete(model: TacticalAnalysis.self)

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
            Task { @MainActor in
                self?.logout()
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

enum SessionError: LocalizedError {
    case missingToken

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Authentication token is missing. Please sign in again."
        }
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
