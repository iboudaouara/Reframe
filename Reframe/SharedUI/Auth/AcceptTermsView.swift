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

struct AcceptTermsView: View {
    @Binding var termsAccepted: Bool

    // On construit le texte enrichi ici pour garder le body propre
    private var legalText: AttributedString {
        // 1. Le texte de base en blanc
        var text = AttributedString("I agree to the Terms of Service and Privacy Policy")
        text.foregroundColor = .white
        text.font = .footnote

        // 2. Configuration du lien "Terms of Service"
        if let range = text.range(of: "Terms of Service") {
            text[range].link = URL(string: AppURL.termsOfUse)
            text[range].underlineStyle = .single // Soulignement explicite
            text[range].foregroundColor = .cyan  // Couleur qui "pop" (Cyan ou ta BrandColor)
        }
        
        // 3. Configuration du lien "Privacy Policy"
        if let range = text.range(of: "Privacy Policy") {
            text[range].link = URL(string: AppURL.privacyPolicy)
            text[range].underlineStyle = .single
            text[range].foregroundColor = .cyan
        }

        return text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 1. La Case à cocher
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    termsAccepted.toggle()
                }
            }) {
                Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(termsAccepted ? .green : .white)
            }
            .buttonStyle(PlainButtonStyle())

            // 2. Le Texte Hybride (Robuste + Style)
            Text(legalText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                // Cette ligne est cruciale pour que le clic sur le lien fonctionne
                // même si le parent a des gestures.
                .environment(\.openURL, OpenURLAction { url in
                    // Tu peux intercepter le clic ici si besoin,
                    // ou laisser le système ouvrir Safari par défaut (return .systemAction)
                    return .systemAction
                })

            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 8)
    }
}
