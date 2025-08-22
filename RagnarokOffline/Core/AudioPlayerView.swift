//
//  AudioPlayerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/22.
//

import AVFAudio
import SwiftUI

struct AudioPlayerView: View {
    var player: AVAudioPlayer

    @State private var isPlaying = false

    var body: some View {
        ZStack {
            if !isPlaying {
                Button {
                    player.play()
                    isPlaying = true
                } label: {
                    Image(systemName: "play.circle")
                        .font(.system(size: 50))
                }
            } else {
                Button {
                    player.pause()
                    isPlaying = false
                } label: {
                    Image(systemName: "pause.circle")
                        .font(.system(size: 50))
                }
            }
        }
        .onDisappear {
            player.stop()
            isPlaying = false
        }
    }
}
