//
//  AudioFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import AVFAudio
import SwiftUI

struct AudioFilePreviewView: View {
    var file: File

    @State private var isPlaying = false

    var body: some View {
        AsyncContentView {
            try await loadAudioFile()
        } content: { data in
            let player = try? AVAudioPlayer(data: data)

            if let player {
                AudioPlayerView(player: player)
            }
        }
        .task {
            #if !os(macOS)
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            #endif
        }
    }

    private func loadAudioFile() async throws -> Data {
        let data = try await file.contents()
        return data
    }
}

//#Preview {
//    AudioFilePreviewView(file: <#T##File#>)
//}
