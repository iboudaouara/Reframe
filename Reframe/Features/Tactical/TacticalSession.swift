import SwiftData
import Foundation

@Model
final class TacticalSession {
    @Attribute(.unique) var id: UUID = UUID()
    var timestamp: Date
    
    // La situation entrée par l'utilisateur
    var situation: String
    
    // Les données de la manoeuvre identifiée (on aplatit la structure pour faciliter le tri/filtrage)
    var maneuverName: String
    var maneuverDescription: String
    var powerScore: Int
    var emotionalImpact: String
    
    // Les contre-mesures proposées (stockées comme un tableau de structs Codable)
    var recommendedMoves: [CounterMove]
    
    // Status de synchro (pour plus tard)
    var syncStatus: String = "pending" 

    init(situation: String, analysis: StrategicAnalysis) {
        self.timestamp = Date()
        self.situation = situation
        
        // On extrait les données pour les rendre accessibles directement
        self.maneuverName = analysis.maneuver.name
        self.maneuverDescription = analysis.maneuver.description
        self.powerScore = analysis.maneuver.powerScore
        self.emotionalImpact = analysis.maneuver.emotionalImpact
        
        self.recommendedMoves = analysis.recommendedMoves
    }
}
