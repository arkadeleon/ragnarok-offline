//
//  MapLoadingView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/7/8.
//

import SwiftUI

struct MapLoadingView: View {
    var progress: Progress

    var body: some View {
        ZStack {
            GameImage(imageName) { image in
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

    private var imageName: String {
        let i = Int.random(in: 1...10)
        let imageName = String(format: "loading%02d.jpg", i)
        return imageName
    }
}

#Preview {
    MapLoadingView(progress: Progress())
        .environment(GameSession.testing)
}
