//
//  GameAudioEngine.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/2.
//

import AVFAudio
import Foundation
import simd

/// Plays decoded sound effects through a pool of player nodes.
///
/// A sound effect can be given a source, and is then played quieter the further the
/// listener stands from it. Its volume keeps up with the listener while it plays.
@MainActor
final class GameAudioEngine {
    private struct Playback {
        var node: AVAudioPlayerNode
        var source: GameAudio.Source?
    }

    private let engine = AVAudioEngine()

    private var idleNodes: [AVAudioPlayerNode] = []
    private var playbacks: [UUID : GameAudioEngine.Playback] = [:]
    private var lastPlayTimes: [String : ContinuousClock.Instant] = [:]

    private var listenerPosition: SIMD3<Float> = .zero

    func setListenerPosition(_ position: SIMD3<Float>) {
        guard position != listenerPosition else {
            return
        }

        listenerPosition = position

        for playback in playbacks.values where playback.source != nil {
            playback.node.volume = volume(from: playback.source)
        }
    }

    func play(_ soundEffect: GameSoundEffect, from source: GameAudio.Source? = nil) {
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
        playbacks[playbackID] = GameAudioEngine.Playback(node: node, source: source)

        node.volume = volume(from: source)
        node.scheduleBuffer(soundEffect.buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task { @MainActor in
                self?.finishPlayback(id: playbackID)
            }
        }
        node.play()
    }

    func stop() {
        for playback in playbacks.values {
            playback.node.stop()
            idleNodes.append(playback.node)
        }
        playbacks.removeAll()

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

    private func volume(from source: GameAudio.Source?) -> Float {
        guard let source else {
            return 1
        }

        guard source.isInRange(ofListenerAtPosition: listenerPosition) else {
            return 0
        }

        let distance = source.distance(toListenerAtPosition: listenerPosition)

        // The volume drops in a straight line from about 1 next to the source
        // to 0 at 25 cells away, and never falls below 0.1.
        return max(1 - abs((distance - 1) * (1 - 0.01) / (25 - 1) + 0.01), 0.1)
    }

    private func finishPlayback(id: UUID) {
        guard let playback = playbacks.removeValue(forKey: id) else {
            return
        }

        playback.node.stop()
        idleNodes.append(playback.node)
    }
}
