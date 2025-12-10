
import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    
    @Environment(UserSession.self) var userSession
    
    var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                    let userId = credential.user
                    let email = credential.email
                    let fullName = credential.fullName?.givenName
                    Task {
                        // userSession.loginWithApple est @MainActor, donc l'appel est sûr.
                        try await userSession.loginWithApple(userIdentifier: userId, email: email, fullName: fullName)
                    }                }
            case .failure(let error):
                print("Apple login failed: \(error)")
            }
        }.signInWithAppleButtonStyle(.white)
            .frame(width: 300, height: 45)
            .padding(6)
    }
}


