import AuthenticationServices
import UIKit
import SwiftUI
import Combine

class SignInWithAppleController: NSObject, ObservableObject {
    private let session: UserSession

    init(session: UserSession) {
        self.session = session
    }

    func startSignInWithAppleFlow() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension SignInWithAppleController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No active window found")
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleID = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        let userID = appleID.user
        let name = appleID.fullName?.givenName ?? "Apple User"
        let email = appleID.email // may be nil after first login

        // **Single call** to session, backend handles signup/login
        session.loginWithApple(userIdentifier: userID, email: email ?? "", fullName: name)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In failed: \(error.localizedDescription)")
    }
}
