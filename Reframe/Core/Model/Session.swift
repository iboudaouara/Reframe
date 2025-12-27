import SwiftUI
import SwiftData

@Observable
final class Session {

    enum State {
        case loading
        case unauthenticated
        case authenticated(User)
        case guest
    }

    private(set) var state: State = .loading
    private var isLoggedInKey = "hasCompletedLogin"

    // TODO: Move elsewhere
    var selectedAvatar: ProfileIcon = .avatar1
    var isPickerPresented: Bool = false
    // TODO ENDS HERE

    var user: User? {
        if case .authenticated(let u) = state { return u }
        return nil
    }

    var isLoggedIn: Bool {
        if case .authenticated = state { return true }
        return false
    }

    var isGuest: Bool {
        if case .guest = state { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        startSessionCheck()
        observeSessionExpiration()
    }

    private func startSessionCheck() {
        Task {
            await checkSessionStatus()
        }
    }

    @MainActor
    func checkSessionStatus() async {
        state = .loading

        try? await Task.sleep(nanoseconds: 500_000_000)

        guard UserDefaults.standard.bool(forKey: isLoggedInKey) else {
            print("🚫 First launch or logged out: Skipping token verification.")
            state = .unauthenticated
            return
        }

        let token = KeychainManager.shared.getToken()

        guard let validToken = token else {
            state = .unauthenticated
            return
        }

        do {
            let user = try await authService.verifyTokenAndFetchUser(token: validToken)

            self.state = .authenticated(user)
            print("✅ Session restaurée : \(user.id)")
        } catch {
            print("❌ Echec restauration session: \(error)")
            self.state = .unauthenticated
        }
    }

    @MainActor
    private func completeAuthentication(with user: User) {
        KeychainManager.shared.saveToken(user.token)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
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

    // TODO: Move elsewhere
    func triggerEditAvatar() {
        isPickerPresented = true
    }
    // TODO ENDS HERE

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
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
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
