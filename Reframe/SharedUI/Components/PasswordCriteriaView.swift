import SwiftUI

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
                Image(
                    systemName: password
                        .range(of: "[A-Z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "[A-Z]", options: .regularExpression) != nil ? .green : .red)
                Text("Une lettre majuscule")
            }
            HStack {
                Image(
                    systemName: password
                        .range(of: "[a-z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "[a-z]", options: .regularExpression) != nil ? .green : .red)
                Text("Une lettre minuscule")
            }
            HStack {
                Image(
                    systemName: password
                        .range(of: "\\d", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "\\d", options: .regularExpression) != nil ? .green : .red)
                Text("Un chiffre")
            }
            HStack {
                Image(
                    systemName: password
                        .range(
                            of: "[!@#$%^&*]",
                            options: .regularExpression
                        ) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "[!@#$%^&*]", options: .regularExpression) != nil ? .green : .red)
                Text("Un caractère spécial (!@#$%^&*)")
            }
        }
        .font(.footnote)
    }
}
