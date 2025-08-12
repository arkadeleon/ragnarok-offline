//
//  AudioFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import AVFoundation
import SwiftUI

struct AudioFilePreviewView: View {
    var file: File

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        AsyncContentView {
            try await loadAudioFile()
        } content: { player in
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
        .task {
            #if !os(macOS)
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            #endif
        }
        .onDisappear {
            if let player {
                player.stop()
                isPlaying = false
            }
        }
    }

    private func loadAudioFile() async throws -> AVAudioPlayer {
        let data = try await file.contents()
        let player = try AVAudioPlayer(data: data)

        self.player = player

        return player
    }
}

//#Preview {
//    AudioFilePreviewView(file: <#T##File#>)
//}
