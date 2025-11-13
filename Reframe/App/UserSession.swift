import SwiftUI

@Observable final class UserSession {
    var user: User?
    var isLoggedIn = false
    var selectedAvatar: ProfileIcon = .avatar1
    var isPickerPresented: Bool = false

    init(
        user: User? = nil,
        isLoggedIn: Bool = false,
        selectedAvatar: ProfileIcon = .avatar1,
        isPickerPresented: Bool = false
    ) {
        self.user = user
        self.isLoggedIn = isLoggedIn
        self.selectedAvatar = selectedAvatar
        self.isPickerPresented = isPickerPresented

        if let token = KeychainManager.shared.getToken() {
            self.isLoggedIn = true
            self.user = User(id: "", name: "Unknown", email: "", token: token)
        }
    }

    func triggerEditAvatar() {
        isPickerPresented = true
    }

    func login(email: String, password: String) {
        AuthService.shared.login(email: email, password: password) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.isLoggedIn = true
                KeychainManager.shared.saveToken(user.token)
            case .failure(let error):
                print("Login failed: \(error)")
                self.isLoggedIn = false
            }
        }
    }

    func signup(name: String, email: String, password: String) {
        AuthService.shared.signup(name: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.isLoggedIn = true
                KeychainManager.shared.saveToken(user.token)
            case .failure(let error):
                print("Signup failed: \(error)")
                self.isLoggedIn = false
            }
        }

    }

    func logout() {
        AuthService.shared.logout()
        self.user = nil
        self.isLoggedIn = false
    }

    func loginWithApple(userIdentifier: String, email: String?, fullName: String?) {
        AuthService.shared.loginWithApple(userIdentifier: userIdentifier, email: email, fullName: fullName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.isLoggedIn = true
                    KeychainManager.shared.saveToken(user.token)
                case .failure(let error):
                    print("Apple login failed: \(error)")
                    self.isLoggedIn = false
                }
            }
        }
    }

    func deleteAccount() {
        guard let token = user?.token else { return }

        AuthService.shared.deleteAccount(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // On considère que si le serveur renvoie une réponse, la suppression a réussi
                    self.logout()
                case .failure(let error):
                    print("Account deletion failed: \(error)")
                }
            }
        }
    }

}

private struct UserSessionKey: EnvironmentKey {
    static let defaultValue: UserSession = UserSession()
}

extension EnvironmentValues {
    var userSession: UserSession {
        get { self[UserSessionKey.self] }
        set { self[UserSessionKey.self] = newValue }
    }
}

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let token: String
}

struct DeleteAccountResponse: Decodable {
    let message: String
}



