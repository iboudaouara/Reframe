//
//  HomeBackground.swift
//  Reframe
//
//  Created by Ibrahim Boudaouara on 2025-11-21.
//

import SwiftUI

struct HomeBackground: View {
    var body: some View {
        Image("Frame")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        LinearGradient(
            colors: [.black.opacity(0.0), .black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
