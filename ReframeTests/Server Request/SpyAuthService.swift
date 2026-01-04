import Testing
import Foundation
@testable import Reframe

class SpyAuthService: AuthServiceProtocol {
    func loginWithApple(data: AppleAuthData, definitiveEmail: String) async throws -> User {
        return User(id: 0, email: "", firstName: "", lastName: "", token: "", profileIcon: .avatar1)
    }

    func loadUserFromSession() async throws -> User {
        return User(id: 0, email: "", firstName: "", lastName: "", token: "", profileIcon: .avatar1)
    }

    var verifyTokenCallCount = 0

    // Cette fonction ne fait rien, sauf compter qu'elle a été appelée
    func verifyTokenAndFetchUser(token: String) async throws -> User {
        verifyTokenCallCount += 1
        // On retourne un faux user juste pour que ça compile
        return User(id: 0, email: "", firstName: "", lastName: "", token: "", profileIcon: .avatar1)
    }

    // --- Le reste du protocole (implémentation vide) ---
    func login(email: String, password: String) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }
    func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }
    func logout() {}
    func deleteAccount(token: String) async throws -> DeleteAccountResponse { return DeleteAccountResponse(message: "") }
    func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User { return User(id: 0, email: "", firstName: "", lastName: "", token: "") }



    // Dans SpyAuthService.swift

    // On ajoute une variable pour espionner si la fonction a été appelée
    var updateProfileIconCalled = false
    var lastIconSent: ProfileIcon?

    func updateProfileIcon(token: String, icon: ProfileIcon) async throws {
        // On note juste que l'appel a eu lieu
        updateProfileIconCalled = true
        lastIconSent = icon

        // On simule un succès immédiat (pas d'erreur rejetée)
        // Si vous vouliez simuler une erreur serveur, vous feriez : throw URLError(.badServerResponse)
    }
}
