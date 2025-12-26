//
//  TacticalRow.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-12-24.
//


import SwiftUI

struct TacticalRow: View {
    let session: TacticalSession

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Indicateur de Score (Cercle coloré)
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .foregroundColor(.red.opacity(0.3))
                    .frame(width: 44, height: 44)
                
                Text("\(session.powerScore)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.red)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                // Nom de la Manoeuvre
                Text(session.maneuverName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Extrait de la situation
                Text(session.situation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Date
                Text(session.timestamp, format: .dateTime.day().month().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
    }
}