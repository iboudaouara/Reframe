import Foundation
import SwiftData

@Model
final class TacticalSession {
    @Attribute(.unique) var id: UUID = UUID()

    var serverId: Int?
    var timestamp: Date
    var situation: String
    var maneuverName: String
    var maneuverDescription: String
    var powerScore: Int
    var emotionalImpact: String
    var recommendedMoves: [CounterMove]
    var syncStatus: String = "pending"

    init(situation: String, analysis: StrategicAnalysis) {
        self.timestamp = Date()
        self.situation = situation
        self.maneuverName = analysis.maneuver.name
        self.maneuverDescription = analysis.maneuver.description
        self.powerScore = analysis.maneuver.powerScore
        self.emotionalImpact = analysis.maneuver.emotionalImpact
        self.recommendedMoves = analysis.recommendedMoves
    }
}
