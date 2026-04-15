//
//  MetalRenderBackend+Sound.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import AVFAudio
import Foundation
import RagnarokResources
import simd

extension MetalRenderBackend {
    func playSound(_ filename: String, at _: SIMD2<Int>) {
        let taskID = UUID()
        soundEffectPlaybackTasks[taskID] = Task { @MainActor [weak self] in
            defer {
                self?.soundEffectPlaybackTasks[taskID] = nil
            }

            guard let self else {
                return
            }

            guard let wavData = await soundEffectData(for: filename) else {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            play(wavData)
        }
    }

    func stopSoundEffects() {
        for task in soundEffectPlaybackTasks.values {
            task.cancel()
        }
        soundEffectPlaybackTasks.removeAll()

        for task in soundEffectDataLoadTasks.values {
            task.cancel()
        }
        soundEffectDataLoadTasks.removeAll()

        for task in soundEffectCleanupTasks.values {
            task.cancel()
        }
        soundEffectCleanupTasks.removeAll()

        for player in activeSoundEffectPlayers.values {
            player.stop()
        }
        activeSoundEffectPlayers.removeAll()
        soundEffectDataCache.removeAll()
    }

    private func soundEffectData(for filename: String) async -> Data? {
        if let cachedData = soundEffectDataCache[filename] {
            return cachedData
        }

        if let existingTask = soundEffectDataLoadTasks[filename] {
            return await existingTask.value
        }

        let loadTask: Task<Data?, Never> = Task { @MainActor [weak self] in
            guard let self else {
                return nil
            }

            let wavPath = ResourcePath(components: ["data", "wav", filename])
            return try? await resourceManager.contentsOfResource(at: wavPath)
        }

        soundEffectDataLoadTasks[filename] = loadTask
        let wavData = await loadTask.value
        soundEffectDataLoadTasks[filename] = nil

        if let wavData {
            soundEffectDataCache[filename] = wavData
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

        soundEffectCleanupTasks[playbackID] = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(cleanupDelay))
            } catch {
                return
            }

            self?.finishSoundEffectPlayback(id: playbackID)
        }
    }
}
