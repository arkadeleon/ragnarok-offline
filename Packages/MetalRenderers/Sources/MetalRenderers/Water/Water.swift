//
//  Water.swift
//  MetalRenderers
//
//  Created by Leon Li on 2023/11/27.
//

import RagnarokFileFormats
import MetalShaders

public struct WaterMesh {
    public var vertices: [WaterVertex] = []
}

public struct Water {
    public var mesh: WaterMesh

    public init(gnd: GND, rsw: RSW) {
        var vertices: [WaterVertex] = []

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        // Compiling mesh
        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                // Check top surface
                if cube.topSurfaceIndex > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurfaceIndex)]

                    // Check if has texture
                    if surface.textureIndex > -1 {
                        // Add water only if it's upper than the ground.
                        if cube.lowestAltitude > rsw.water.level - rsw.water.waveHeight {
                            // Water texture is 128px * 128px
                            // Each surface contains 4 tiles, each tile is 32px * 32px
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
        }

        mesh = WaterMesh(vertices: vertices)
    }
}
