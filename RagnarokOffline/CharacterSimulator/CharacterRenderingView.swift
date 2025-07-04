//
//  CharacterRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/13.
//

import ROCore
import SwiftUI

struct CharacterRenderingView: View {
    @Environment(AppModel.self) private var appModel

    private var characterSimulator: CharacterSimulator {
        appModel.characterSimulator
    }

    var body: some View {
        ZStack {
            if let animatedImage = characterSimulator.animatedImage {
                AnimatedImageView(animatedImage: animatedImage)
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
        .environment(AppModel())
}
