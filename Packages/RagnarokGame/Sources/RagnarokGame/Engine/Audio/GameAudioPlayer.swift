//
//  GameAudioPlayer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/4.
//

import AVFAudio
import Foundation
import RagnarokCore
import RagnarokResources

@MainActor
final class GameAudioPlayer {
    private let resourceManager: ResourceManager

    private var bgmName: String?
    private var bgmPlayer: AVAudioPlayer?

    private var soundEffectDataCache: [String : Data] = [:]
    private var soundEffectDataLoadTasks: [String : Task<Data?, Never>] = [:]
    private var activeSoundEffectPlayers: [UUID : AVAudioPlayer] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager

        #if !os(macOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            logger.warning("Failed to configure game audio playback: \(error, privacy: .public)")
        }
        #endif
    }

    // MARK: - BGM

    func playLoginBGM() async {
        await playBGM(named: "01.mp3")
    }

    func playBGM(forMapName mapName: String) async {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return
        }

        await playBGM(named: mp3Name)
    }

    private func playBGM(named mp3Name: String) async {
        guard bgmName != mp3Name else {
            return
        }

        stopBGM()

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return
        }

        bgmName = mp3Name
        bgmPlayer = try? AVAudioPlayer(data: bgmData)
        bgmPlayer?.numberOfLoops = -1
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        bgmName = nil
    }

    // MARK: - Sound Effect

    func playButtonSoundEffect() {
        playSoundEffect(named: K2L("버튼소리.wav"))
    }

    func playSoundEffect(named soundName: String, after delay: Duration = .zero) {
        Task { [weak self] in
            if delay > .zero {
                try await Task.sleep(for: delay)
            }
            guard let self else {
                return
            }
            guard let wavData = await soundEffectData(forSoundName: soundName) else {
                return
            }
            play(wavData)
        }
    }

    private func soundEffectData(forSoundName soundName: String) async -> Data? {
        if let cachedData = soundEffectDataCache[soundName] {
            return cachedData
        }

        if let existingTask = soundEffectDataLoadTasks[soundName] {
            return await existingTask.value
        }

        let loadTask: Task<Data?, Never> = Task { [weak self] in
            guard let self else {
                return nil
            }

            let wavPath = ResourcePath(components: ["data", "wav", soundName])
            return try? await resourceManager.contentsOfResource(at: wavPath)
        }

        soundEffectDataLoadTasks[soundName] = loadTask
        let wavData = await loadTask.value
        soundEffectDataLoadTasks[soundName] = nil

        if let wavData {
            soundEffectDataCache[soundName] = wavData
        }

        return wavData
    }

    private func play(_ wavData: Data) {
        let playbackID = UUID()
        guard let player = try? AVAudioPlayer(data: wavData) else {
            return
        }
        let cleanupDelay = max(player.duration, 0) + 0.1

        activeSoundEffectPlayers[playbackID] = player
        player.prepareToPlay()

        guard player.play() else {
            activeSoundEffectPlayers[playbackID]?.stop()
            activeSoundEffectPlayers[playbackID] = nil
            return
        }

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(cleanupDelay))
            guard let self else {
                return
            }
            activeSoundEffectPlayers[playbackID]?.stop()
            activeSoundEffectPlayers[playbackID] = nil
        }
    }

    func stopSoundEffects() {
        for task in soundEffectDataLoadTasks.values {
            task.cancel()
        }
        soundEffectDataLoadTasks.removeAll()

        for player in activeSoundEffectPlayers.values {
            player.stop()
        }
        activeSoundEffectPlayers.removeAll()

        soundEffectDataCache.removeAll()
    }
}
