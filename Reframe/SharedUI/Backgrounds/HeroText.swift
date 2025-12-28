import SwiftUI

struct HeroText: View {
    let text: LocalizedStringKey
    
    var body: some View {
        Text(text)
            .font(.system(size: 40, weight: .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading) // Permet d'écrire sur plusieurs lignes
            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            .frame(maxWidth: .infinity, alignment: .leading) // Prend la largeur dispo
            .minimumScaleFactor(0.5)
    }
}
