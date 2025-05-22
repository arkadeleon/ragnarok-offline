//
//  Water.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//

import ROFileFormats
import ROShaders

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
                        if cube.lowestAltitude / 5 > rsw.water.level - rsw.water.waveHeight {
                            let x0 = ((Float(x) + 0).truncatingRemainder(dividingBy: 5) / 5)
                            let y0 = ((Float(y) + 0).truncatingRemainder(dividingBy: 5) / 5)
                            let x1 = ((Float(x) + 1).truncatingRemainder(dividingBy: 5) / 5) > 0 ? ((Float(x) + 1).truncatingRemainder(dividingBy: 5) / 5) : 1
                            let y1 = ((Float(y) + 1).truncatingRemainder(dividingBy: 5) / 5) > 0 ? ((Float(y) + 1).truncatingRemainder(dividingBy: 5) / 5) : 1

                            let v0 = WaterVertex(
                                position: [(Float(x) + 0) * 2, rsw.water.level, (Float(y) + 0) * 2],
                                textureCoordinate: [x0, y0]
                            )
                            let v1 = WaterVertex(
                                position: [(Float(x) + 1) * 2, rsw.water.level, (Float(y) + 0) * 2],
                                textureCoordinate: [x1, y0]
                            )
                            let v2 = WaterVertex(
                                position: [(Float(x) + 1) * 2, rsw.water.level, (Float(y) + 1) * 2],
                                textureCoordinate: [x1, y1]
                            )
                            let v3 = WaterVertex(
                                position: [(Float(x) + 1) * 2, rsw.water.level, (Float(y) + 1) * 2],
                                textureCoordinate: [x1, y1]
                            )
                            let v4 = WaterVertex(
                                position: [(Float(x) + 0) * 2, rsw.water.level, (Float(y) + 1) * 2],
                                textureCoordinate: [x0, y1]
                            )
                            let v5 = WaterVertex(
                                position: [(Float(x) + 0) * 2, rsw.water.level, (Float(y) + 0) * 2],
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
