//
//  TargetSelectorMesh.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/13.
//

import Foundation
import RagnarokShaders
import simd

/// The marker over the selected target, in sprite pixels of which 32 make one world unit.
/// It is a flat ring with a gem above it. The shapes never change, so they are built once.
struct TargetSelectorMesh {
    /// A ring 35 pixels wide and 20 pixels tall, centered on (0, 0).
    var ringVertices: [TargetSelectorVertex]

    /// A gem 14 pixels wide and 10 pixels tall, pointing down, with the middle of its top edge at (0, 0).
    var gemVertices: [TargetSelectorVertex]

    init() {
        let outlineColor = SIMD4<Float>(0.09, 0.09, 0.11, 1)
        let ringLightColor = SIMD4<Float>(0.969, 0.969, 1, 1)
        let ringDarkColor = SIMD4<Float>(0.541, 0.502, 0.612, 1)

        ringVertices = []
        gemVertices = []

        ringVertices += makeRingVertices(outerRadius: [17.5, 10], innerRadius: [16.5, 9], color: outlineColor)
        ringVertices += makeRingVertices(outerRadius: [16.5, 9], innerRadius: [15, 7.8], color: ringLightColor)
        ringVertices += makeRingVertices(outerRadius: [15, 7.8], innerRadius: [14, 7], color: ringDarkColor)
        ringVertices += makeRingVertices(outerRadius: [14, 7], innerRadius: [13.5, 6.5], color: outlineColor)

        gemVertices = makeGemVertices()
    }

    private func makeRingVertices(
        outerRadius: SIMD2<Float>,
        innerRadius: SIMD2<Float>,
        color: SIMD4<Float>
    ) -> [TargetSelectorVertex] {
        let segmentCount = 32

        var vertices: [TargetSelectorVertex] = []
        vertices.reserveCapacity(segmentCount * 6)

        for segment in 0..<segmentCount {
            let angle0 = Float(segment) / Float(segmentCount) * 2 * .pi
            let angle1 = Float(segment + 1) / Float(segmentCount) * 2 * .pi
            let direction0 = SIMD2<Float>(cos(angle0), sin(angle0))
            let direction1 = SIMD2<Float>(cos(angle1), sin(angle1))

            vertices += makeQuadVertices(
                direction0 * outerRadius,
                direction1 * outerRadius,
                direction1 * innerRadius,
                direction0 * innerRadius,
                color: color
            )
        }

        return vertices
    }

    private func makeGemVertices() -> [TargetSelectorVertex] {
        // Points are measured down from the gem's top edge.
        func point(_ x: Float, _ y: Float) -> SIMD2<Float> {
            [x, -y]
        }

        let outlineColor = SIMD4<Float>(0.09, 0.09, 0.11, 1)
        let crownLeftColor = SIMD4<Float>(0.608, 0.565, 0.678, 1)
        let crownRightColor = SIMD4<Float>(0.808, 0.796, 0.882, 1)
        let pavilionLeftColor = SIMD4<Float>(0.965, 0.957, 0.98, 1)
        let pavilionRightColor = SIMD4<Float>(0.839, 0.831, 0.914, 1)

        let outline = [
            point(-5, 0), point(5, 0), point(7, 1.5), point(7, 3.5), point(0, 10), point(-7, 3.5), point(-7, 1.5),
        ]
        var vertices: [TargetSelectorVertex] = []
        for index in 1..<(outline.count - 1) {
            vertices += makeTriangleVertices(outline[0], outline[index], outline[index + 1], color: outlineColor)
        }

        vertices += makeQuadVertices(point(-4.5, 1), point(0, 1), point(0, 3.6), point(-6, 3.6), color: crownLeftColor)
        vertices += makeTriangleVertices(point(-4.5, 1), point(-6, 3.6), point(-6, 2), color: crownLeftColor)
        vertices += makeQuadVertices(point(0, 1), point(4.5, 1), point(6, 3.6), point(0, 3.6), color: crownRightColor)
        vertices += makeTriangleVertices(point(4.5, 1), point(6, 2), point(6, 3.6), color: crownRightColor)
        vertices += makeTriangleVertices(point(-6, 3.6), point(0, 3.6), point(0, 8.6), color: pavilionLeftColor)
        vertices += makeTriangleVertices(point(0, 3.6), point(6, 3.6), point(0, 8.6), color: pavilionRightColor)

        return vertices
    }

    private func makeQuadVertices(
        _ a: SIMD2<Float>,
        _ b: SIMD2<Float>,
        _ c: SIMD2<Float>,
        _ d: SIMD2<Float>,
        color: SIMD4<Float>
    ) -> [TargetSelectorVertex] {
        makeTriangleVertices(a, b, c, color: color) + makeTriangleVertices(c, d, a, color: color)
    }

    private func makeTriangleVertices(
        _ a: SIMD2<Float>,
        _ b: SIMD2<Float>,
        _ c: SIMD2<Float>,
        color: SIMD4<Float>
    ) -> [TargetSelectorVertex] {
        [
            TargetSelectorVertex(position: a, color: color),
            TargetSelectorVertex(position: b, color: color),
            TargetSelectorVertex(position: c, color: color),
        ]
    }
}
