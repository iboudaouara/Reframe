import SwiftUI

struct LegalLink: View {
    var title: LocalizedStringKey
    var url: String
    
    var body: some View {
        Link(title, destination: URL(string: url)!)
            .font(.footnote)
            .foregroundStyle(.blue)
            .padding(.vertical, 6)
    }
}

#Preview {
    LegalLink(title: "Privacy Policy", url: AppURL.privacyPolicy)
    LegalLink(title: "Terms of Use", url: AppURL.termsOfUse)
}
