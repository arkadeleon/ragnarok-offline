//
//  RealityMapAudioPlayer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import AVFAudio
import Foundation
import RagnarokResources
import RealityKit

@MainActor
final class RealityMapAudioPlayer {
    private let resourceManager: ResourceManager
    private unowned let entityCache: RealityEntityCache

    private var soundEffectResourceCache: [String : AudioBufferResource] = [:]
    private var soundEffectResourceLoadTasks: [String : Task<AudioBufferResource?, Never>] = [:]

    init(resourceManager: ResourceManager, entityCache: RealityEntityCache) {
        self.resourceManager = resourceManager
        self.entityCache = entityCache
    }

    func playBGM(forMapName mapName: String, on worldEntity: Entity) async {
        guard let audioResource = await audioResource(forMapName: mapName) else {
            return
        }

        worldEntity.components.set(AudioLibraryComponent(resources: [
            "BGM": audioResource
        ]))
        worldEntity.components.set(AmbientAudioComponent())
        worldEntity.playAudio(audioResource)
    }

    func playSound(named soundName: String, on objectID: GameObjectID) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let resource = await soundEffectResource(for: soundName) else { return }
            guard let entity = entityCache.loadedObjectEntity(for: objectID) else { return }
            entity.playAudio(resource)
        }
    }

    func stopSoundEffects() {
        for task in soundEffectResourceLoadTasks.values {
            task.cancel()
        }
        soundEffectResourceLoadTasks.removeAll()
        soundEffectResourceCache.removeAll()
    }

    private func audioResource(forMapName mapName: String) async -> AudioResource? {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return nil
        }

        guard let audioBuffer = AVAudioPCMBuffer.load(from: bgmData) else {
            return nil
        }

        let configuration = AudioBufferResource.Configuration(shouldLoop: true)
        return try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
    }

    private func soundEffectResource(for soundName: String) async -> AudioBufferResource? {
        if let cachedResource = soundEffectResourceCache[soundName] {
            return cachedResource
        }

        if let existingTask = soundEffectResourceLoadTasks[soundName] {
            return await existingTask.value
        }

        let loadTask: Task<AudioBufferResource?, Never> = Task { @MainActor [weak self] in
            guard let self else {
                return nil
            }

            let wavPath = ResourcePath(components: ["data", "wav", soundName])
            guard let wavData = try? await resourceManager.contentsOfResource(at: wavPath) else {
                return nil
            }

            guard let audioBuffer = AVAudioPCMBuffer.load(from: wavData) else {
                return nil
            }

            let configuration = AudioBufferResource.Configuration(shouldLoop: false)
            return try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
        }

        soundEffectResourceLoadTasks[soundName] = loadTask
        let resource = await loadTask.value
        soundEffectResourceLoadTasks[soundName] = nil

        if let resource {
            soundEffectResourceCache[soundName] = resource
        }

        return resource
    }
}
