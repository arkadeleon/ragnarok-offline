//
//  TargetSelector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/13.
//

import Foundation
import RagnarokModels

struct TargetSelector {
    let objectID: GameObjectID
    let showTime: TimeInterval

    func gemDrop(atTime time: TimeInterval) -> Float {
        // How far the gem drops at every 100 milliseconds. Between them the drop is interpolated.
        let drops: [Float] = [0, 1, 3, 8, 10, 11, 11, 11, 10, 8, 5, 2, 0, 0, 0, 0, 0, 0, 0, 0]
        let frame = max(time - showTime, 0) / 0.1
        let frameIndex = Int(frame) % drops.count
        let fraction = Float(frame - frame.rounded(.down))
        return drops[frameIndex] + (drops[(frameIndex + 1) % drops.count] - drops[frameIndex]) * fraction
    }
}
