//
//  MapLoadingView.swift
//  GameView
//
//  Created by Leon Li on 2025/7/8.
//

import GameCore
import SwiftUI

struct MapLoadingView: View {
    var progress: Double

    var body: some View {
        ZStack {
            GameImage("loading01.jpg") { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .ignoresSafeArea()

            VStack {
                Spacer()

                GameProgressBar(progress: progress)
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    MapLoadingView(progress: 0.5)
        .environment(GameSession.previewing)
}
