//
//  CharacterRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/13.
//

import ROCore
import SwiftUI

struct CharacterRenderingView: View {
    @Environment(CharacterSimulator.self) private var characterSimulator

    var body: some View {
        ZStack {
            if let animation = characterSimulator.animation {
                AnimatedImageView(animatedImage: AnimatedImage(animation: animation))
                    .offset(x: -animation.pivot.x, y: -animation.pivot.y)
                    .offset(y: 50)
                    .scaleEffect(2)
            }

            HStack {
                Button {
                    characterSimulator.configuration.rotateClockwise()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                #if !os(macOS)
                .buttonBorderShape(.circle)
                #endif

                Spacer()

                Button {
                    characterSimulator.configuration.rotateCounterClockwise()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                #if !os(macOS)
                .buttonBorderShape(.circle)
                #endif
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CharacterRenderingView()
        .environment(CharacterSimulator())
}
