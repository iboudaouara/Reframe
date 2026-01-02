import SwiftUI

enum AuthError: Error {
    case noTokenFound
    case invalidToken
}

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User
    func logout()
    func deleteAccount(token: String) async throws -> DeleteAccountResponse
    func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User
    func verifyTokenAndFetchUser(token: String) async throws -> User
    func loadUserFromSession() async throws -> User
}

final class AuthService : AuthServiceProtocol {
    static let shared = AuthService()
    let server = ReframeServer.shared
    
    func login(email: String, password: String) async throws -> User {
        try await server.request(endpoint: "login", method: "POST", body: ["email": email, "password": password])
    }

    func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        try await server
            .request(endpoint: "signup", method: "POST", body: [
                "first_name": firstName,
                "last_name": lastName,
                "email": email,
                "password": password
            ])
    }

    // Rappel pour AuthService
    func loadUserFromSession() async throws -> User {
        guard let token = KeychainManager.shared.getToken() else {
            throw AuthError.noTokenFound
        }
        // Ici on suppose que tu as une fonction pour valider le token ou créer l'user
        return try await verifyTokenAndFetchUser(token: token)
    }


    func logout() {
        KeychainManager.shared.deleteToken()
    }

    /*
    func loginWithApple(userIdentifier: String, email: String?, fullName: String?) async throws -> User {
        try await server.request(endpoint: "apple-login", method: "POST", body: ["apple_id": userIdentifier])
    }*/

    func deleteAccount(token: String) async throws -> DeleteAccountResponse {
        try await server
            .request(endpoint: "delete-account", method: "DELETE", headers: ["Authorization": "Bearer \(token)"])
    }

    func verifyTokenAndFetchUser(token: String) async throws -> User {
        let headers = ["Authorization": "Bearer \(token)"]
        print("Token to verify: \(token)")
        return try await server.request(endpoint: "verify-token", method: "POST", headers: headers)
    }
}

struct DeleteAccountResponse: Decodable {
    let message: String
}



struct AppleLoginRequest: Encodable {
    let email: String?
    let first_name: String?
    let last_name: String?
}

extension AuthService {

    func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User {
            let requestBody = AppleLoginRequest(
                email: email,
                first_name: firstName,
                last_name: lastName
            )

            return try await server.request(
                endpoint: "apple-login",
                method: "POST",
                body: requestBody
            )
        }
}
