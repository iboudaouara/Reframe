import Foundation

// La manoeuvre (Le Diagnostic de l'IA)
// L'IA ne génère plus du texte, elle identifie une "Classe" de comportement.
struct Maneuver: Identifiable, Codable {
    let id: Int
    let name: String // Ex.: "Délégation de Charge", "Double Contrainte"
    let description: String // Ex.: "L'antagoniste vous force à faire le travail à sa place"
    let powerScore: Int // Ex.: 80 (L'antagoniste domine)
    let emotionalImpacT: String // "Frustration, Sentiment d'infériorité"
}

// La Réplique (La Contre-Attaque du Playbook)
struct CounterMove: Identifiable, Codable {
    let id: Int
    let text: String // "J'ai oublié mes lunettes, tu peux me le lire?"
    let author: String?
    let successRate: Double
    let usageCount: Int
    let isVerified: Bool

    var trustLevel: TrustLevel {
        switch successRate {
        case 0.8...1.0: return .high
        case 0.5..<0.8: return .medium
        default: return .experimental
        }
    }

    enum TrustLevel {
        case high, medium, experimental
    }
}

struct StrategicAnalysis: Decodable {
    let maneuver: Maneuver
    let recommendedMoves: [CounterMove] // Top 3 des répliques
}
