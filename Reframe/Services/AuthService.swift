import Foundation

final class AuthService : AuthServiceProtocol {
    static let shared = AuthService()
    let server = ReframeServer.shared


    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        server.request(endpoint: "login", method: "POST", body: ["email": email, "password": password], completion: completion)
    }


    func signup(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        server.request(endpoint: "signup", method: "POST", body: ["name": name, "email": email, "password": password], completion: completion)
    }

    func logout() {
        KeychainManager.shared.deleteToken()
    }

    func loginWithApple(userIdentifier: String, email: String?, fullName: String?, completion: @escaping (Result<User, Error>) -> Void) {
        server.request(endpoint: "apple-login", method: "POST", body: ["apple_id": userIdentifier], completion: completion)
    }

    func deleteAccount(token: String, completion: @escaping (Result<DeleteAccountResponse, Error>) -> Void) {
        server.request(endpoint: "delete-account", method: "DELETE", headers: ["Authorization": "Bearer \(token)"], completion: completion)
    }
}

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signup(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout()
    func deleteAccount(token: String, completion: @escaping (Result<DeleteAccountResponse, Error>) -> Void)
    func loginWithApple(userIdentifier: String, email: String?, fullName: String?, completion: @escaping (Result<User, Error>) -> Void)
}

