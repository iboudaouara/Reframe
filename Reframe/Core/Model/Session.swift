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

    var selectedAvatar: ProfileIcon = .avatar1
    var isPickerPresented: Bool = false

    //private let insightService = InsightService.shared

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
        self.state = .authenticated(user)
    }

    @MainActor
    func synchronize(modelContext: ModelContext) async {
        guard case .authenticated(let currentUser) = state else {
            print("⚠️ Synchronisation annulée : Pas d'utilisateur connecté")
            return
        }

        print("🔄 Sync pour user: \(currentUser.id)")

        // ❌ SUPPRIMER OU COMMENTER CES LIGNES :
        // clearLocalInsights(modelContext: modelContext)
        // try? await insightService.synchronize(modelContext: modelContext, token: currentUser.token)

        // Note: Tu pourras ajouter ici la synchro du TacticalService plus tard.
    }
    /*
     @MainActor
     func synchronize(modelContext: ModelContext) async {
     guard case .authenticated(let currentUser) = state else {
     print("⚠️ Synchronisation annulée : Pas d'utilisateur connecté")
     return
     }

     print("🔄 Sync pour user: \(currentUser.id)")

     // Nettoyage préventif
     clearLocalInsights(modelContext: modelContext)

     try? await insightService.synchronize(modelContext: modelContext, token: currentUser.token)
     }

     */

    enum SessionError: LocalizedError {
        case missingToken

        var errorDescription: String? {
            switch self {
            case .missingToken:
                return "Authentication token is missing. Please sign in again."
            }
        }
    }

    func triggerEditAvatar() {
        isPickerPresented = true
    }

    @MainActor
    func continueAsGuest(modelContext: ModelContext) {
        //clearLocalInsights(modelContext: modelContext)
        state = .guest
    }

    @MainActor
    func login(email: String, password: String) async throws {
        state = .loading
        do {
            let user = try await authService.login(email: email, password: password)
            completeAuthentication(with: user)
        } catch {
            state = .unauthenticated // Ou revenir à l'état précédent
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

        // ✅ REMPLACER Insight.self PAR TacticalSession.self
        try modelContext.delete(model: TacticalSession.self)

        logout()
    }

    /*
     @MainActor
     func deleteAccount(modelContext: ModelContext) async throws {
     guard case .authenticated(let currentUser) = state else {
     throw SessionError.missingToken
     }

     _ = try await AuthService.shared.deleteAccount(token: currentUser.token)
     try modelContext.delete(model: Insight.self)
     logout()
     }*/
    /*    @MainActor
     private func clearLocalInsights(modelContext: ModelContext) {
     do {
     try modelContext.delete(model: Insight.self)
     print("✅ Insights locaux supprimés")
     } catch {
     print("❌ Erreur lors de la suppression des insights locaux:", error)
     }
     }*/

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
