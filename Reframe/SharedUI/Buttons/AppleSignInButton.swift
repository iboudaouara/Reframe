
import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    
    @Environment(Session.self) var userSession
    
    var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                    let userId = credential.user
                    let email = credential.email
                    let _ = credential.fullName?.givenName

                    let firstName = credential.fullName?.givenName
                    let lastName = credential.fullName?.familyName

                    Task {
                        try await userSession
                            .loginWithApple(
                                userIdentifier: userId,
                                email: email,
                                firstName: firstName,
                                lastName: lastName
                            )
                    }                }
            case .failure(let error):
                print("Apple login failed: \(error)")
            }
        }.signInWithAppleButtonStyle(.white)
            .frame(width: 300, height: 45)
            .padding(6)
    }
}


