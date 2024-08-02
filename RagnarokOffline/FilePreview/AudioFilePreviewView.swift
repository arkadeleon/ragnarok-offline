//
//  AudioFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import AVFoundation
import SwiftUI

enum AudioFilePreviewError: Error {
    case invalidAudioFile
}

struct AudioFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<AVAudioPlayer> = .notYetLoaded
    @State private var isPlaying = false

    var body: some View {
        AsyncContentView(status: status) { player in
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

            await loadAudio()
        }
        .onDisappear {
            if case .loaded(let player) = status {
                player.stop()
                isPlaying = false
            }
        }
    }

    private func loadAudio() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        if let data = file.file.contents(), let player = try? AVAudioPlayer(data: data) {
            status = .loaded(player)
        } else {
            status = .failed(AudioFilePreviewError.invalidAudioFile)
        }
    }
}

//#Preview {
//    AudioFilePreviewView(file: <#T##File#>)
//}
