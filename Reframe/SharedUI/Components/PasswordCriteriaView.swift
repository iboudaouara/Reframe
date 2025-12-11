import SwiftUI

struct PasswordCriteriaView: View {
    let password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "x.circle")
                    .foregroundColor(password.count >= 8 ? .green : .red)
                Text(LocalizedStringKey("At least 8 characters"))
            }
            HStack {
                Image(
                    systemName: password
                        .range(of: "[A-Z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "[A-Z]", options: .regularExpression) != nil ? .green : .red)
                Text(LocalizedStringKey("One uppercase letter"))
            }
            HStack {
                Image(
                    systemName: password
                        .range(of: "[a-z]", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "[a-z]", options: .regularExpression) != nil ? .green : .red)
                Text(LocalizedStringKey("One lowercase letter"))
            }
            HStack {
                Image(
                    systemName: password
                        .range(of: "\\d", options: .regularExpression) != nil ? "checkmark.circle.fill" : "x.circle"
                )
                .foregroundColor(password.range(of: "\\d", options: .regularExpression) != nil ? .green : .red)
                Text(LocalizedStringKey("One number"))
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
                Text(LocalizedStringKey("One special character (!@#$%^&*)"))
            }
        }
        .font(.footnote)
    }
}
