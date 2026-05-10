//
//  LoginFlowAudioPlayer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/10.
//

import AVFAudio
import Foundation
import RagnarokCore
import RagnarokResources

final class LoginFlowAudioPlayer: GameAudioPlayer {
    private let resourceManager: ResourceManager

    private var bgmPlayer: AVAudioPlayer?
    private var buttonSoundData: Data?
    private var activeSoundPlayers: Set<AVAudioPlayer> = []

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
        super.init()
    }

    func playBGM() async {
        guard bgmPlayer == nil else {
            return
        }

        let bgmPath = ResourcePath(components: ["BGM", "01.mp3"])
        guard let data = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return
        }

        bgmPlayer = try? AVAudioPlayer(data: data)
        bgmPlayer?.numberOfLoops = -1
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    func playButtonSound() {
        Task { [weak self] in
            guard let self else {
                return
            }
            if buttonSoundData == nil {
                let path = ResourcePath(components: ["data", "wav", K2L("버튼소리.wav")])
                buttonSoundData = try? await resourceManager.contentsOfResource(at: path)
            }
            guard let data = buttonSoundData else {
                return
            }
            play(data)
        }
    }

    private func play(_ data: Data) {
        guard let player = try? AVAudioPlayer(data: data) else {
            return
        }

        let cleanupDelay = max(player.duration, 0) + 0.1
        activeSoundPlayers.insert(player)
        player.prepareToPlay()

        guard player.play() else {
            activeSoundPlayers.remove(player)
            return
        }

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(cleanupDelay))
            self?.activeSoundPlayers.remove(player)
        }
    }
}
