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

public struct WaterRenderAsset {
    public var mesh: WaterMesh
    public var lighting: WorldLighting
    public var textureImage: CGImage?

    public init(gnd: GND, rsw: RSW, lighting: WorldLighting, textureImage: CGImage?) {
        var vertices: [WaterVertex] = []

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                if cube.topSurfaceIndex > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurfaceIndex)]

                    if surface.textureIndex > -1, cube.lowestAltitude > rsw.water.level - rsw.water.waveHeight {
                        let x0 = Float((x + 0) % 2) / 2
                        let y0 = Float((y + 0) % 2) / 2
                        var x1 = Float((x + 1) % 2) / 2
                        var y1 = Float((y + 1) % 2) / 2
                        if x1 == 0 { x1 = 1 }
                        if y1 == 0 { y1 = 1 }

                        let v0 = WaterVertex(
                            position: [(Float(x) + 0) * 2, rsw.water.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )
                        let v1 = WaterVertex(
                            position: [(Float(x) + 1) * 2, rsw.water.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x1, y0]
                        )
                        let v2 = WaterVertex(
                            position: [(Float(x) + 1) * 2, rsw.water.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v3 = WaterVertex(
                            position: [(Float(x) + 1) * 2, rsw.water.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v4 = WaterVertex(
                            position: [(Float(x) + 0) * 2, rsw.water.level / 5, (Float(y) + 1) * 2],
                            textureCoordinate: [x0, y1]
                        )
                        let v5 = WaterVertex(
                            position: [(Float(x) + 0) * 2, rsw.water.level / 5, (Float(y) + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )

                        vertices += [v0, v1, v2, v3, v4, v5]
                    }
                }
            }
        }

        mesh = WaterMesh(vertices: vertices)

        self.lighting = lighting
        self.textureImage = textureImage
    }
}
