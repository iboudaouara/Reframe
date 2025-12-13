// Reframe/SharedUI/Auth/AcceptTermsView.swift

import SwiftUI

// AJOUT: Un style simple pour que le Toggle ressemble à une case à cocher
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .green : .white)
                configuration.label
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// AJOUT: Une structure interne pour afficher les liens cliquables
private struct LegalLinkText: View {
    var title: LocalizedStringKey
    var url: String

    var body: some View {
        Link(title, destination: URL(string: url)!)
            .font(.footnote)
            .underline()
            .foregroundColor(.white)
    }
}

/// Vue affichant la case à cocher pour accepter les conditions d'utilisation et la politique de confidentialité.
struct AcceptTermsView: View {
    @Binding var termsAccepted: Bool

    var body: some View {
        Toggle(isOn: $termsAccepted) {
            // UTILISATION DE LOCALIZEDSTRINGKEY POUR TOUT LE TEXTE
            HStack(spacing: 2) {
                // Clé à ajouter: "I agree to the"
                Text("I agree to the")

                LegalLinkText(title: "Terms of Service", url: AppURL.termsOfUse)

                // Clé à ajouter: "and"
                Text("and")

                LegalLinkText(title: "Privacy Policy", url: AppURL.privacyPolicy)
            }
            .font(.footnote)
            .foregroundColor(.white)
        }
        .toggleStyle(CheckboxToggleStyle())
        .padding(.horizontal, 32)
        .padding(.vertical, 8)
    }
}
// ... (Preview si nécessaire)
