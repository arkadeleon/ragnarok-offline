//
//  MetalMapHitTester.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics

@MainActor
final class MetalMapHitTester {
    weak var renderer: MapRuntimeRenderer?
    weak var scene: MapScene?

    func configure(renderer: MapRuntimeRenderer, scene: MapScene) {
        self.renderer = renderer
        self.scene = scene
    }

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        guard let renderer, let scene else {
            return nil
        }

        let spriteBillboardRenderer = renderer.spriteBillboardRenderer

        if let hitBoxes = spriteBillboardRenderer?.hitBoxes {
            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if scene.state.objects[objectID] != nil || objectID == scene.state.player.id {
                    return .mapObject(objectID: objectID)
                }
            }
            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if scene.state.items[objectID] != nil {
                    return .item(objectID: objectID)
                }
            }
        }

        let viewport = renderer.lastViewport
        guard let matrices = renderer.lastRenderMatrices,
              let (origin, direction) = MetalRaycaster.ray(
                through: screenPoint,
                viewport: viewport,
                matrices: matrices
              ) else {
            return nil
        }

        return MetalRaycaster.groundHit(origin: origin, direction: direction, mapGrid: scene.mapGrid)
    }
}

#endif
