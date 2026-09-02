//
//  GameAudioEngine.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import AVFAudio
import Foundation

/// Plays decoded sound effects through a pool of player nodes.
@MainActor
final class GameAudioEngine {
    private let engine = AVAudioEngine()

    private var idleNodes: [AVAudioPlayerNode] = []
    private var activeNodes: [UUID : AVAudioPlayerNode] = [:]
    private var lastPlayTimes: [String : ContinuousClock.Instant] = [:]

    func play(_ soundEffect: GameSoundEffect) {
        let now = ContinuousClock.now
        if let lastPlayTime = lastPlayTimes[soundEffect.name], now - lastPlayTime < .milliseconds(100) {
            return
        }

        let node = idleNodes.popLast() ?? makeNode()

        guard startIfNeeded() else {
            idleNodes.append(node)
            return
        }

        lastPlayTimes[soundEffect.name] = now

        let playbackID = UUID()
        activeNodes[playbackID] = node

        node.scheduleBuffer(soundEffect.buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task { @MainActor in
                self?.finishPlayback(id: playbackID)
            }
        }
        node.play()
    }

    func stop() {
        for node in activeNodes.values {
            node.stop()
            idleNodes.append(node)
        }
        activeNodes.removeAll()
        lastPlayTimes.removeAll()

        engine.stop()
    }

    private func startIfNeeded() -> Bool {
        if engine.isRunning {
            return true
        }

        do {
            try engine.start()
            return true
        } catch {
            logger.warning("Failed to start the game audio engine: \(error, privacy: .public)")
            return false
        }
    }

    private func makeNode() -> AVAudioPlayerNode {
        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: GameAudio.format)
        return node
    }

    private func finishPlayback(id: UUID) {
        guard let node = activeNodes.removeValue(forKey: id) else {
            return
        }

        node.stop()
        idleNodes.append(node)
    }
}
