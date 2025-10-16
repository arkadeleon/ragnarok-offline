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
        GeometryReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    GameImage("loading01.jpg") { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }

                    VStack {
                        Spacer()

                        GameProgressBar(progress: progress)
                            .padding(.bottom, 50)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MapLoadingView(progress: 0.5)
        .frame(width: 400, height: 300)
        .environment(GameSession.previewing)
}
