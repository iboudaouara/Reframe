import Foundation
import SwiftUI

// Vérifie si l'email a un format valide
func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return predicate.evaluate(with: email)
}

// Vérifie si le mot de passe respecte certains critères
func isValidPassword(_ password: String) -> Bool {
    // Minimum 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial
    let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*])[A-Za-z\\d!@#$%^&*]{8,}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return predicate.evaluate(with: password)
}

struct PasswordCriteriaView: View {
    let password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.count >= 8 ? .green : .red)
                Text("Au moins 8 caractères")
            }
            HStack {
                Image(systemName: password.range(of: "[A-Z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.range(of: "[A-Z]", options: .regularExpression) != nil ? .green : .red)
                Text("Une lettre majuscule")
            }
            HStack {
                Image(systemName: password.range(of: "[a-z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.range(of: "[a-z]", options: .regularExpression) != nil ? .green : .red)
                Text("Une lettre minuscule")
            }
            HStack {
                Image(systemName: password.range(of: "\\d", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.range(of: "\\d", options: .regularExpression) != nil ? .green : .red)
                Text("Un chiffre")
            }
            HStack {
                Image(systemName: password.range(of: "[!@#$%^&*]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.range(of: "[!@#$%^&*]", options: .regularExpression) != nil ? .green : .red)
                Text("Un caractère spécial (!@#$%^&*)")
            }
        }
        .font(.footnote)
    }
}


struct SignUpView: View {
    @Environment(\.userSession) var session
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LoginBackground()
                ScrollView(showsIndicators: false) {

                    VStack(spacing: 16) {
                        Spacer()
                        LoginHeaderView()
                        
                        LoginFormView(email: $email, password: $password, mode: .signup, onSubmit: {
                            if !isValidEmail(email) {
                                    alertMessage = "Adresse email invalide"
                                    showAlert = true
                                    return
                                }

                                // Vérifier mot de passe
                                if !isValidPassword(password) {
                                    alertMessage = "Mot de passe invalide : minimum 8 caractères, 1 majuscule, 1 chiffre, 1 caractère spécial."
                                    showAlert = true
                                    return
                                }
                            print("Signup tapped") // À retirer
                            session.signup(name: "New User", email: email, password: password)
                        })
                        
                        LegalFooterView()
                        Spacer()
                    }.frame(minHeight: geo.size.height)
                }.frame(minWidth: geo.size.width, minHeight: geo.size.height).background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }.ignoresSafeArea()
        }
    }
}


#Preview {
    let session = UserSession()
    SignUpView()
        .environment(\.userSession, session)
}
