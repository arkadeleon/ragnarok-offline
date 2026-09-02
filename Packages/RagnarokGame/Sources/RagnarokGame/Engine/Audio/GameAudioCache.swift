//
//  GameAudioCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import AVFAudio
import Foundation
import RagnarokResources

@MainActor
final class GameAudioCache {
    private let resourceManager: ResourceManager

    private var soundEffects: [String : GameSoundEffect] = [:]
    private var loadTasks: [String : Task<Void, Never>] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func soundEffect(forSoundName soundName: String) async -> GameSoundEffect? {
        if let cachedSoundEffect = soundEffects[soundName] {
            return cachedSoundEffect
        }

        if let existingTask = loadTasks[soundName] {
            await existingTask.value
            return soundEffects[soundName]
        }

        let loadTask = Task { [weak self] in
            guard let self else {
                return
            }

            let wavPath = ResourcePath(components: ["data", "wav", soundName])
            guard let wavData = try? await resourceManager.contentsOfResource(at: wavPath) else {
                return
            }
            guard let buffer = await AVAudioPCMBuffer.buffer(from: wavData, format: GameAudio.format) else {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            soundEffects[soundName] = GameSoundEffect(name: soundName, buffer: buffer)
        }

        loadTasks[soundName] = loadTask
        await loadTask.value
        loadTasks[soundName] = nil

        return soundEffects[soundName]
    }

    func removeAll() {
        for task in loadTasks.values {
            task.cancel()
        }
        loadTasks.removeAll()

        soundEffects.removeAll()
    }
}
