import SwiftUI

struct LegalFooterView: View {
    var body: some View {
        VStack(spacing: 4) {
            LegalLink(title: "Privacy Policy", url: AppURL.privacyPolicy)
            LegalLink(title: "Terms of Service", url: AppURL.termsOfUse)
        }
        .padding(.vertical, 16)
    }
}
