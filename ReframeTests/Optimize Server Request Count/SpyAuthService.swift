import Testing
import Foundation
@testable import Reframe

class SpyAuthService: AuthServiceProtocol {
    var verifyTokenCallCount = 0

    // Cette fonction ne fait rien, sauf compter qu'elle a été appelée
    func verifyTokenAndFetchUser(token: String) async throws -> User {
        verifyTokenCallCount += 1
        // On retourne un faux user juste pour que ça compile
        return User(id: 0, email: "", firstName: "", lastName: "", token: "")
    }

    // --- Le reste du protocole (implémentation vide) ---
    func login(email: String, password: String) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }
    func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }
    func logout() {}
    func deleteAccount(token: String) async throws -> DeleteAccountResponse { return DeleteAccountResponse(message: "") }
    func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }
}
