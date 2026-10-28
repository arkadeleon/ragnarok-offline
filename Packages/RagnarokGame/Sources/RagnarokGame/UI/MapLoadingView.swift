//
//  MapLoadingView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/7/8.
//

import SwiftUI

struct MapLoadingView: View {
    var progress: Progress

    @State private var imageName = String(format: "loading%02d.jpg", Int.random(in: 1...10))

    var body: some View {
        ZStack {
            GameImage(imageName) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .ignoresSafeArea()

            GameProgressBar(progress: progress)
        }
    }
}

#Preview {
    MapLoadingView(progress: Progress())
        .environment(GameContext.testing)
}
