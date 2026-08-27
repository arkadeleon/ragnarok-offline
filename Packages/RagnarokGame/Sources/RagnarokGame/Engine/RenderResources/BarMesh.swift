//
//  BarMesh.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/27.
//

import RagnarokModels
import RagnarokShaders
import simd

/// The quads that draw a map object's bars, in sprite pixels of which 32 make one world unit.
struct BarMesh {
    let vertices: [SpriteVertex]

    /// An object's health and spell point bars, stacked around its anchor.
    static func mesh(hp: Int, maxHp: Int, sp: Int, maxSp: Int, objectType: MapObjectType) -> BarMesh {
        guard maxHp > 0 else {
            return BarMesh(vertices: [])
        }

        let barHeight: Float = 5
        let barSpacing: Float = 1

        let healthPercentage = Float(hp) / Float(maxHp)

        let healthColor: SIMD4<Float> = switch objectType {
        case .monster, .abr, .bionic:
            healthPercentage < 0.25 ? [1, 1, 0, 1] : [1, 0, 0.906, 1]
        default:
            healthPercentage < 0.25 ? [1, 0, 0, 1] : [0.063, 0.937, 0.129, 1]
        }

        let spellPointsColor = SIMD4<Float>(0.094, 0.388, 0.871, 1)

        var bars: [(percentage: Float, color: SIMD4<Float>)] = [
            (healthPercentage, healthColor)
        ]
        if maxSp > 0 {
            bars.append((Float(sp) / Float(maxSp), spellPointsColor))
        }

        // Center the stack on the anchor.
        let height = barHeight * Float(bars.count) - barSpacing * Float(bars.count - 1)
        var top = height / 2

        var vertices: [SpriteVertex] = []
        for bar in bars {
            vertices += makeBarVertices(
                top: top,
                height: barHeight,
                percentage: bar.percentage,
                fillColor: bar.color
            )
            top -= barHeight - barSpacing
        }
        return BarMesh(vertices: vertices)
    }

    /// A caster's skill cast progress bar, sitting above its anchor.
    static func mesh(cast: MapObjectCast, time: ContinuousClock.Instant) -> BarMesh {
        let barTop: Float = 90
        let barHeight: Float = 6
        let castColor = SIMD4<Float>(0, 1, 0, 1)

        let vertices = makeBarVertices(
            top: barTop,
            height: barHeight,
            percentage: cast.progress(at: time),
            fillColor: castColor
        )
        return BarMesh(vertices: vertices)
    }

    /// One bordered bar with a filled part, centered on x with its top edge at `top`.
    private static func makeBarVertices(
        top: Float,
        height: Float,
        percentage: Float,
        fillColor: SIMD4<Float>
    ) -> [SpriteVertex] {
        let barWidth: Float = 60
        let borderWidth: Float = 1
        let borderColor = SIMD4<Float>(0.063, 0.094, 0.612, 1)
        let backgroundColor = SIMD4<Float>(0.259, 0.259, 0.259, 1)

        let left = -barWidth / 2
        let bottom = top - height

        let innerWidth = barWidth - borderWidth * 2
        let innerHeight = height - borderWidth * 2
        let fillWidth = max(0, innerWidth * min(max(percentage, 0), 1))

        return makeQuadVertices(
            left: left,
            bottom: bottom,
            width: barWidth,
            height: height,
            color: borderColor
        )
        + makeQuadVertices(
            left: left + borderWidth,
            bottom: bottom + borderWidth,
            width: innerWidth,
            height: innerHeight,
            color: backgroundColor
        )
        + makeQuadVertices(
            left: left + borderWidth,
            bottom: bottom + borderWidth,
            width: fillWidth,
            height: innerHeight,
            color: fillColor
        )
    }

    private static func makeQuadVertices(
        left: Float,
        bottom: Float,
        width: Float,
        height: Float,
        color: SIMD4<Float>
    ) -> [SpriteVertex] {
        guard width > 0, height > 0 else {
            return []
        }

        let right = left + width
        let top = bottom + height

        return [
            SpriteVertex(position: [left, bottom], textureCoordinate: [0, 1], color: color),
            SpriteVertex(position: [right, bottom], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [left, top], textureCoordinate: [0, 0], color: color),
            SpriteVertex(position: [right, bottom], textureCoordinate: [1, 1], color: color),
            SpriteVertex(position: [right, top], textureCoordinate: [1, 0], color: color),
            SpriteVertex(position: [left, top], textureCoordinate: [0, 0], color: color),
        ]
    }
}
