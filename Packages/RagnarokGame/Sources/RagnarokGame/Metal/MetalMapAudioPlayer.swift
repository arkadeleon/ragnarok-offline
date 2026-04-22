//
//  MetalMapAudioPlayer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import AVFAudio
import Foundation
import RagnarokResources

@MainActor
final class MetalMapAudioPlayer {
    private let resourceManager: ResourceManager

    private var bgmPlayer: AVAudioPlayer?
    private var soundEffectDataCache: [String : Data] = [:]
    private var soundEffectDataLoadTasks: [String : Task<Data?, Never>] = [:]
    private var activeSoundEffectPlayers: [UUID : AVAudioPlayer] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func playBGM(forMapName mapName: String) async {
        bgmPlayer?.stop()
        bgmPlayer = await loadBGMPlayer(forMapName: mapName)
        bgmPlayer?.numberOfLoops = -1
        bgmPlayer?.play()
    }

    func playSound(named soundName: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let wavData = await soundEffectData(for: soundName) else { return }
            play(wavData)
        }
    }

    func stopAll() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        stopSoundEffects()
    }

    private func stopSoundEffects() {
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

    private func loadBGMPlayer(forMapName mapName: String) async -> AVAudioPlayer? {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return nil
        }

        return try? AVAudioPlayer(data: bgmData)
    }

    private func soundEffectData(for soundName: String) async -> Data? {
        if let cachedData = soundEffectDataCache[soundName] {
            return cachedData
        }

        if let existingTask = soundEffectDataLoadTasks[soundName] {
            return await existingTask.value
        }

        let loadTask: Task<Data?, Never> = Task { @MainActor [weak self] in
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
            finishSoundEffectPlayback(id: playbackID)
            return
        }

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(cleanupDelay))
            guard let self else { return }
            finishSoundEffectPlayback(id: playbackID)
        }
    }

    private func finishSoundEffectPlayback(id: UUID) {
        activeSoundEffectPlayers[id]?.stop()
        activeSoundEffectPlayers[id] = nil
    }
}
