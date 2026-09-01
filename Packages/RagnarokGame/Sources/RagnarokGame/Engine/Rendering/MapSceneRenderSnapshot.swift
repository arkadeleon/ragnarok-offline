//
//  MapSceneRenderSnapshot.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import Metal
import RagnarokRendering
import RagnarokShaders
import simd

/// Everything needed to draw one state of a map scene.
///
/// A snapshot is built once per frame so every view draws the same contents from
/// its own camera.
struct MapSceneRenderSnapshot {
    struct Effect {
        let resourceGroup: EffectRenderResourceGroup
        let attachedWorldPosition: SIMD3<Float>?
    }

    struct Bar {
        let vertices: [SpriteVertex]
        let worldPosition: SIMD3<Float>
    }

    struct TileSelector {
        let position: SIMD2<Int>
        let cell: MapGrid.Cell
    }

    struct CombatText {
        let vertices: [SpriteVertex]
        let worldPosition: SIMD3<Float>
        let texture: any MTLTexture
    }

    var fog: Fog
    var world: WorldRenderResource?
    var tileSelector: TileSelector?
    var spriteDrawables: [SpriteLayerDrawable] = []
    var effects: [Effect] = []
    var bars: [Bar] = []
    var combatTexts: [CombatText] = []
}
