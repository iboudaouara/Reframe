//
//  TacticalDetailView.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-12-24.
//


import SwiftUI

struct TacticalDetailView: View {
    let session: TacticalSession
    @Environment(\.dismiss) private var dismiss

    // On reconstruit l'objet Maneuver pour pouvoir réutiliser la ManeuverCard existante
    private var reconstructedManeuver: Maneuver {
        Maneuver(
            id: 0, // L'ID importe peu pour l'affichage
            name: session.maneuverName,
            description: session.maneuverDescription,
            powerScore: session.powerScore,
            emotionalImpact: session.emotionalImpact
        )
    }

    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").ignoresSafeArea() // Fond sombre comme le Dashboard

            ScrollView {
                VStack(spacing: 24) {
                    // Rappel de la situation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SITUATION INITIALE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                        
                        Text(session.situation)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Carte de la manoeuvre (Réutilisation de ton composant existant)
                    ManeuverCard(maneuver: reconstructedManeuver)
                        .padding(.horizontal)

                    Divider().background(Color.white.opacity(0.2))

                    // Liste des répliques
                    Text("OPTIONS SUGGÉRÉES")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(session.recommendedMoves) { move in
                        CounterMoveRow(move: move)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Rapport Tactique")
        .navigationBarTitleDisplayMode(.inline)
    }
}