//
//  WaterRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import RagnarokFileFormats
import RagnarokShaders

public struct WaterMesh {
    public var vertices: [WaterVertex] = []
}

public struct WaterParameters {
    public var level: Float
    public var type: Int32
    public var waveHeight: Float
    public var waveSpeed: Float
    public var wavePitch: Float
    public var animationSpeed: Int32
    public var opacity: Float

    public init(gnd: GND, rsw: RSW) {
        // GND v1.8+ water overrides RSW water
        if let water = gnd.water {
            level = water.level
            type = water.type
            waveHeight = water.waveHeight
            waveSpeed = water.waveSpeed
            wavePitch = water.wavePitch
            animationSpeed = water.animationSpeed
        } else {
            level = rsw.water.level
            type = rsw.water.type
            waveHeight = rsw.water.waveHeight
            waveSpeed = rsw.water.waveSpeed
            wavePitch = rsw.water.wavePitch
            animationSpeed = rsw.water.animationSpeed
        }
        opacity = (type == 4 || type == 6) ? 1.0 : 0.8
    }
}

public struct WaterRenderAsset {
    public var mesh: WaterMesh
    public var parameters: WaterParameters
    public var lighting: WorldLighting
    public var textureImages: [CGImage]

    public init(gnd: GND, parameters: WaterParameters, lighting: WorldLighting, textureImages: [CGImage]) {
        self.parameters = parameters
        self.lighting = lighting
        self.textureImages = textureImages

        var vertices: [WaterVertex] = []

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                if cube.topSurfaceIndex > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurfaceIndex)]

                    if surface.textureIndex > -1, cube.lowestAltitude > parameters.level - parameters.waveHeight {
                        let x0 = Float((x + 0) % 2) / 2
                        let y0 = Float((y + 0) % 2) / 2
                        var x1 = Float((x + 1) % 2) / 2
                        var y1 = Float((y + 1) % 2) / 2
                        if x1 == 0 { x1 = 1 }
                        if y1 == 0 { y1 = 1 }

                        let v0 = WaterVertex(
                            position: [(Float(x) + 0) * 2, parameters.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )
                        let v1 = WaterVertex(
                            position: [(Float(x) + 1) * 2, parameters.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x1, y0]
                        )
                        let v2 = WaterVertex(
                            position: [(Float(x) + 1) * 2, parameters.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v3 = WaterVertex(
                            position: [(Float(x) + 1) * 2, parameters.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v4 = WaterVertex(
                            position: [(Float(x) + 0) * 2, parameters.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x0, y1]
                        )
                        let v5 = WaterVertex(
                            position: [(Float(x) + 0) * 2, parameters.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )

                        vertices += [v0, v1, v2, v3, v4, v5]
                    }
                }
            }
        }

        mesh = WaterMesh(vertices: vertices)
    }
}
