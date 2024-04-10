//
//  Water.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal
import RagnarokOfflineFileFormats

struct WaterMesh {
    var vertices: [WaterVertex] = []
    var textures: [MTLTexture?] = []
}

struct Water {
    var mesh: WaterMesh

    init(gnd: GND, rsw: RSW, textureProvider: (String) -> MTLTexture?) {
        var vertices: [WaterVertex] = []

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        // Compiling mesh
        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                // Check top surface
                if cube.topSurface > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurface)]

                    // Check if has texture
                    if surface.textureIndex > -1 {
                        // Add water only if it's upper than the ground.
                        if cube.bottomLeft > rsw.water.level - rsw.water.waveHeight ||
                            cube.bottomRight > rsw.water.level - rsw.water.waveHeight ||
                            cube.topLeft > rsw.water.level - rsw.water.waveHeight ||
                            cube.topRight > rsw.water.level - rsw.water.waveHeight {

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

        var textures: [MTLTexture?] = []
        for i in 0..<32 {
            let textureName = String(format: "워터\\water%03d.jpg", i)
            let texture = textureProvider(textureName)
            textures.append(texture)
        }

        mesh = WaterMesh(vertices: vertices, textures: textures)
    }
}
