//
//  Gauge.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/12.
//

import RagnarokModels
import RagnarokShaders
import simd

/// An object's health and spell point bars, drawn as a billboard around its anchor.
struct Gauge {
    private let objectType: MapObjectType

    private let hp: Int
    private let maxHp: Int
    private let sp: Int
    private let maxSp: Int

    /// Bar size in sprite pixels, of which 32 make one world unit.
    private let barWidth: Float = 60
    private let barHeight: Float = 5
    private let borderWidth: Float = 1
    private let barSpacing: Float = 1

    private let borderColor = SIMD4<Float>(0.063, 0.094, 0.612, 1)
    private let backgroundColor = SIMD4<Float>(0.259, 0.259, 0.259, 1)
    private let spellPointsColor = SIMD4<Float>(0.094, 0.388, 0.871, 1)

    init(object: MapSceneMapObject) {
        objectType = object.type
        hp = object.hp
        maxHp = object.maxHp
        sp = object.sp
        maxSp = object.maxSp
    }

    /// The quads that draw the bars, in sprite space around the object's anchor.
    func makeVertices() -> [SpriteVertex] {
        guard maxHp > 0 else {
            return []
        }

        let healthPercentage = Float(hp) / Float(maxHp)

        var bars: [(percentage: Float, color: SIMD4<Float>)] = [
            (healthPercentage, healthColor(percentage: healthPercentage))
        ]
        if maxSp > 0 {
            bars.append((Float(sp) / Float(maxSp), spellPointsColor))
        }

        // Center the stack on the anchor.
        let height = barHeight * Float(bars.count) - barSpacing * Float(bars.count - 1)
        var top = height / 2

        var vertices: [SpriteVertex] = []
        for bar in bars {
            vertices += makeBarVertices(top: top, percentage: bar.percentage, fillColor: bar.color)
            top -= barHeight - barSpacing
        }
        return vertices
    }

    private func healthColor(percentage: Float) -> SIMD4<Float> {
        switch objectType {
        case .monster, .abr, .bionic:
            percentage < 0.25 ? [1, 1, 0, 1] : [1, 0, 0.906, 1]
        default:
            percentage < 0.25 ? [1, 0, 0, 1] : [0.063, 0.937, 0.129, 1]
        }
    }

    private func makeBarVertices(
        top: Float,
        percentage: Float,
        fillColor: SIMD4<Float>
    ) -> [SpriteVertex] {
        let left = -barWidth / 2
        let bottom = top - barHeight

        let innerWidth = barWidth - borderWidth * 2
        let fillWidth = max(0, innerWidth * min(max(percentage, 0), 1))

        return makeQuadVertices(
            left: left,
            bottom: bottom,
            width: barWidth,
            height: barHeight,
            color: borderColor
        )
        + makeQuadVertices(
            left: left + borderWidth,
            bottom: bottom + borderWidth,
            width: innerWidth,
            height: barHeight - borderWidth * 2,
            color: backgroundColor
        )
        + makeQuadVertices(
            left: left + borderWidth,
            bottom: bottom + borderWidth,
            width: fillWidth,
            height: barHeight - borderWidth * 2,
            color: fillColor
        )
    }

    private func makeQuadVertices(
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
