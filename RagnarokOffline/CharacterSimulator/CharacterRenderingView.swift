//
//  CharacterRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/13.
//

import ROCore
import SwiftUI

struct CharacterRenderingView: View {
    @Binding var configuration: CharacterConfiguration
    var animatedImage: AnimatedImage?

    var body: some View {
        ZStack {
            if let animatedImage {
                AnimatedImageView(animatedImage: animatedImage)
                    .scaleEffect(2)
            }

            HStack {
                Button {
                    configuration.rotateClockwise()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                #if !os(macOS)
                .buttonBorderShape(.circle)
                #endif

                Spacer()

                Button {
                    configuration.rotateCounterClockwise()
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
    @Previewable @State var configuration = CharacterConfiguration()

    CharacterRenderingView(configuration: $configuration, animatedImage: nil)
}
