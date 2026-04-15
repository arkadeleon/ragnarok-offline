//
//  RealityRenderBackend+Sound.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import AVFAudio
import Foundation
import RagnarokResources
import RealityKit
import simd

extension RealityRenderBackend {
    func playSound(_ filename: String, at position: SIMD2<Int>) {
        let taskID = UUID()
        soundEffectPlaybackTasks[taskID] = Task { @MainActor [weak self] in
            defer {
                self?.soundEffectPlaybackTasks[taskID] = nil
            }

            guard let self else {
                return
            }

            guard let resource = await soundEffectResource(for: filename) else {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            play(resource, at: position)
        }
    }

    func stopSoundEffects() {
        for task in soundEffectPlaybackTasks.values {
            task.cancel()
        }
        soundEffectPlaybackTasks.removeAll()

        for task in soundEffectResourceLoadTasks.values {
            task.cancel()
        }
        soundEffectResourceLoadTasks.removeAll()

        for task in transientSoundCleanupTasks.values {
            task.cancel()
        }
        transientSoundCleanupTasks.removeAll()

        for child in Array(rootEntity.children) where child.name == transientSoundEntityName {
            child.stopAllAudio()
            child.removeFromParent()
        }

        soundEffectResourceCache.removeAll()
    }

    private func soundEffectResource(for filename: String) async -> AudioBufferResource? {
        if let cachedResource = soundEffectResourceCache[filename] {
            return cachedResource
        }

        if let existingTask = soundEffectResourceLoadTasks[filename] {
            return await existingTask.value
        }

        let loadTask: Task<AudioBufferResource?, Never> = Task { @MainActor [weak self] in
            guard let self else {
                return nil
            }

            let wavPath = ResourcePath(components: ["data", "wav", filename])
            guard let wavData = try? await resourceManager.contentsOfResource(at: wavPath) else {
                return nil
            }

            guard let audioBuffer = AVAudioPCMBuffer.load(from: wavData) else {
                return nil
            }

            let configuration = AudioBufferResource.Configuration(shouldLoop: false)
            return try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
        }

        soundEffectResourceLoadTasks[filename] = loadTask
        let resource = await loadTask.value
        soundEffectResourceLoadTasks[filename] = nil

        if let resource {
            soundEffectResourceCache[filename] = resource
        }

        return resource
    }

    private func play(_ resource: AudioBufferResource, at gridPosition: SIMD2<Int>) {
        guard let scene else {
            return
        }

        let entity = Entity()
        entity.name = transientSoundEntityName
        entity.position = scene.position(for: gridPosition)
        rootEntity.addChild(entity)
        entity.playAudio(resource)

        let taskID = UUID()
        transientSoundCleanupTasks[taskID] = Task { @MainActor [weak self, weak entity] in
            defer {
                self?.transientSoundCleanupTasks[taskID] = nil
            }

            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }

            guard let entity else {
                return
            }

            entity.stopAllAudio()
            entity.removeFromParent()
        }
    }
}
