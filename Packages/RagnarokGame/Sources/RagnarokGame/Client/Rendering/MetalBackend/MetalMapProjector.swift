//
//  MetalMapProjector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import simd

final class MetalMapProjector: MapProjector {
    weak var renderer: MapRuntimeRenderer?

    func configure(renderer: MapRuntimeRenderer) {
        self.renderer = renderer
    }

    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        guard let renderer,
              let matrices = renderer.lastRenderMatrices else {
            return nil
        }

        let viewport = renderer.lastViewport
        guard viewport.width > 0, viewport.height > 0 else {
            return nil
        }

        // worldPosition is already in world space; apply P × V only, no model matrix.
        let pv = matrices.projectionMatrix * matrices.viewMatrix
        let clip = pv * SIMD4<Float>(worldPosition.x, worldPosition.y, worldPosition.z, 1)

        guard clip.w > 0 else {
            return nil
        }

        let ndcX = clip.x / clip.w
        let ndcY = clip.y / clip.w

        guard (-1...1).contains(ndcX), (-1...1).contains(ndcY) else {
            return nil
        }

        // NDC → screen coordinates (top-left origin; NDC +Y is up, screen +Y is down).
        let sx = viewport.minX + CGFloat((ndcX + 1) * 0.5) * viewport.width
        let sy = viewport.minY + CGFloat((1 - ndcY) * 0.5) * viewport.height

        return CGPoint(x: sx, y: sy)
    }
}

#endif
