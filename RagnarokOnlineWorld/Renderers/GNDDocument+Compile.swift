//
//  GNDDocument+Compile.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

extension GNDDocument.Contents {

    private struct LightmapAtlas {
        var u1: Float
        var u2: Float
        var v1: Float
        var v2: Float
    }

    private func createLightmapImage() -> [UInt8] {
        let count     = Int(lightmap.count)
        let data      = lightmap.data
        let per_cell  = Int(lightmap.per_cell)

        let width     = Int(roundf(sqrtf(Float(count))))
        let height    = Int(ceilf(sqrtf(Float(count))))
        let _width    = Int(powf(2, ceilf(logf(Float(width) * 8) / logf(2))))
        let _height   = Int(powf(2, ceilf(logf(Float(height) * 8) / logf(2))))

        var out: [UInt8] = Array(repeating: 0, count: _width * _height * 4)

        for i in 0..<count {
            let pos   = i * 4 * per_cell
            let x     = (i % width) * 8
            let y     = (i / width) * 8

            for _x in 0..<8 {
                for _y in 0..<8 {
                    let idx = ((x + _x) + (y + _y) * _width) * 4
                    out[idx + 0] = (data[pos + per_cell + (_x + _y * 8) * 3 + 0] >> 4) << 4 // Posterisation
                    out[idx + 1] = (data[pos + per_cell + (_x + _y * 8) * 3 + 1] >> 4) << 4 // Posterisation
                    out[idx + 2] = (data[pos + per_cell + (_x + _y * 8) * 3 + 2] >> 4) << 4 // Posterisation
                    out[idx + 3] = data[pos + (_x + _y * 8)]
                }
            }
        }

        return out
    }

    private func createTilesColorImage() -> [UInt8] {
        let width = Int(self.width)
        let height = Int(self.height)
        var data: [UInt8] = Array(repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let cell = surfaces[x + y * width]
                if cell.tile_up > -1 {
                    let index = (x + y * width) * 4
                    let color = tiles[Int(cell.tile_up)].color
                    data[index + 0] = color[0]
                    data[index + 1] = color[1]
                    data[index + 2] = color[2]
                    data[index + 3] = color[3]
                }
            }
        }

        return data
    }

    private func createShadowmapData() -> [UInt8] {
        let width = Int(self.width)
        let height = Int(self.height)

        var out: [UInt8] = Array(repeating: 0, count: (width * 8) * (height * 8))

        for y in 0..<height {
            for x in 0..<width {
                let cell = surfaces[x + y * width]

                if cell.tile_up > -1 {
                    let tile_up = Int(cell.tile_up)
                    let light = Int(tiles[tile_up].light)
                    let per_cell = Int(lightmap.per_cell)
                    let index = light * 4 * per_cell

                    for i in 0..<8 {
                        for j in 0..<8 {
                            out[(x * 8 + i) + (y * 8 + j) * (width * 8)] = lightmap.data[index + i + j * 8]
                        }
                    }
                } else {
                    for i in 0..<8 {
                        for j in 0..<8 {
                            out[(x * 8 + i) + (y * 8 + j) * (width * 8)] = 255
                        }
                    }
                }
            }
        }

        return out
    }

    private func getSmoothNormal() -> [[Vector3<Float>]] {
        let width = Int(self.width)
        let height = Int(self.height)

        let count = width * height
        var tmp: [Vector3<Float>?] = Array(repeating: nil, count: count)

        let vec_in_tmp: (Int) -> Vector3<Float> = { (i: Int) -> Vector3<Float> in
            if i > 0 && i < tmp.count {
                return tmp[i] ?? Vector3<Float>()
            } else {
                return Vector3<Float>()
            }
        }

        let normal = Array(repeating: Vector3<Float>(), count: 4)
        var normals = Array(repeating: normal, count: count)

        for y in 0..<height {
            for x in 0..<width {
                tmp[x + y * width] = Vector3<Float>()
                let cell = surfaces[x + y * width]

                if cell.tile_up > -1 {
                    let fx = Float(x)
                    let fy = Float(y)
                    let a: Vector3<Float> = [(fx+0)*2, cell.height[0], (fy+0)*2]
                    let b: Vector3<Float> = [(fx+1)*2, cell.height[1], (fy+0)*2]
                    let c: Vector3<Float> = [(fx+1)*2, cell.height[3], (fy+1)*2]
                    let d: Vector3<Float> = [(fx+0)*2, cell.height[2], (fy+1)*2]
                    tmp[x + y * width] = SGLMath.calcNormal(a, b, c, d)
                }
            }
        }

        for y in 0..<height {
            for x in 0..<width {
                var n = normals[x + y * width]

                n[0] = n[0] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[0] = n[0] + vec_in_tmp((x - 1) + (y + 0) * width)
                n[0] = n[0] + vec_in_tmp((x - 1) + (y - 1) * width)
                n[0] = n[0] + vec_in_tmp((x + 0) + (y - 1) * width)
                n[0] = normalize(n[0])

                n[1] = n[1] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[1] = n[1] + vec_in_tmp((x + 1) + (y + 0) * width)
                n[1] = n[1] + vec_in_tmp((x + 1) + (y - 1) * width)
                n[1] = n[1] + vec_in_tmp((x + 0) + (y - 1) * width)
                n[1] = normalize(n[1])

                n[2] = n[2] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[2] = n[2] + vec_in_tmp((x + 1) + (y + 0) * width)
                n[2] = n[2] + vec_in_tmp((x + 1) + (y + 1) * width)
                n[2] = n[2] + vec_in_tmp((x + 0) + (y + 1) * width)
                n[2] = normalize(n[2])

                n[3] = n[3] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[3] = n[3] + vec_in_tmp((x - 1) + (y + 0) * width)
                n[3] = n[3] + vec_in_tmp((x - 1) + (y + 1) * width)
                n[3] = n[3] + vec_in_tmp((x + 0) + (y + 1) * width)
                n[3] = normalize(n[3])

                normals[x + y * width] = n
            }
        }

        return normals
    }

    func compile(WATER_LEVEL: Float, WATER_HEIGHT: Float) -> (mesh: [GroundVertex], waterMesh: [WaterVertex]) {
        let _width = Int(self.width)
        let _height = Int(self.height)

        let normals = getSmoothNormal()

        var mesh: [GroundVertex] = []
        var water: [WaterVertex] = []

        let l_count_w  = roundf(sqrtf(Float(lightmap.count)))
        let l_count_h  = ceilf(sqrtf(Float(lightmap.count)))
        let l_width    = powf(2, ceilf(logf(l_count_w * 8) / logf(2)))
        let l_height   = powf(2, ceilf(logf(l_count_h * 8) / logf(2)))
        let lightmap_atlas: (Int) -> LightmapAtlas = { (i: Int) -> LightmapAtlas in
            return LightmapAtlas(
                u1: ((Float(i % Int(l_count_w)) + 0.125) / l_count_w) * ((l_count_w * 8) / l_width),
                u2: ((Float(i % Int(l_count_w)) + 0.875) / l_count_w) * ((l_count_w * 8) / l_width),
                v1: ((Float(i / Int(l_count_w)) + 0.125) / l_count_h) * ((l_count_h * 8) / l_height),
                v2: ((Float(i / Int(l_count_w)) + 0.875) / l_count_h) * ((l_count_h * 8) / l_height)
            )
        }

        let width = Float(_width)
        let height = Float(_height)

        // Compiling mesh
        for _y in 0..<_height {
            for _x in 0..<_width {
                let x = Float(_x)
                let y = Float(_y)

                let cell_a = surfaces[ _x + _y * _width ]
                let h_a    = cell_a.height

                // Check tile up
                if (cell_a.tile_up > -1) {
                    let tile = tiles[Int(cell_a.tile_up)]

                    // Check if has texture
                    let n = normals[ _x + _y * _width ]
                    let l = lightmap_atlas(Int(tile.light))

                    let v0 = GroundVertex(
                        position: [(x + 0) * 2, h_a[0], (y + 0) * 2],
                        normal: [n[0][0], n[0][1], n[0][1]],
                        textureCoordinate: [tile.u1, tile.v1],
                        lightmapCoordinate: [l.u1, l.v1],
                        tileColorCoordinate: [(x + 0.5) / width, (y + 0.5) / height]
                    )
                    let v1 = GroundVertex(
                        position: [(x + 1) * 2, h_a[1], (y + 0) * 2],
                        normal: [n[1][0], n[1][1], n[1][1]],
                        textureCoordinate: [tile.u2, tile.v2],
                        lightmapCoordinate: [l.u2, l.v1],
                        tileColorCoordinate: [(x + 1.5) / width, (y + 0.5) / height]
                    )
                    let v2 = GroundVertex(
                        position: [(x + 1) * 2, h_a[3], (y + 1) * 2],
                        normal: [n[2][0], n[2][1], n[2][1]],
                        textureCoordinate: [tile.u4, tile.v4],
                        lightmapCoordinate: [l.u2, l.v2],
                        tileColorCoordinate: [(x + 1.5) / width, (y + 1.5) / height]
                    )
                    let v3 = GroundVertex(
                        position: [(x + 1) * 2, h_a[3], (y + 1) * 2],
                        normal: [n[2][0], n[2][1], n[2][1]],
                        textureCoordinate: [tile.u4, tile.v4],
                        lightmapCoordinate: [l.u2, l.v2],
                        tileColorCoordinate: [(x + 1.5) / width, (y + 1.5) / height]
                    )
                    let v4 = GroundVertex(
                        position: [(x + 0) * 2, h_a[2], (y + 1) * 2],
                        normal: [n[3][0], n[3][1], n[3][1]],
                        textureCoordinate: [tile.u3, tile.v3],
                        lightmapCoordinate: [l.u1, l.v2],
                        tileColorCoordinate: [(x + 0.5) / width, (y + 1.5) / height]
                    )
                    let v5 = GroundVertex(
                        position: [(x + 0) * 2, h_a[0], (y + 0) * 2],
                        normal: [n[0][0], n[0][1], n[0][1]],
                        textureCoordinate: [tile.u1, tile.v1],
                        lightmapCoordinate: [l.u1, l.v1],
                        tileColorCoordinate: [(x + 0.5) / width, (y + 0.5) / height]
                    )

                    mesh += [v0, v1, v2, v3, v4, v5]

                    // Add water only if it's upper than the ground.
                    if h_a[0] > WATER_LEVEL - WATER_HEIGHT ||
                        h_a[1] > WATER_LEVEL - WATER_HEIGHT ||
                        h_a[2] > WATER_LEVEL - WATER_HEIGHT ||
                        h_a[3] > WATER_LEVEL - WATER_HEIGHT {

                        let x0 = ((x + 0) % 5 / 5)
                        let y0 = ((y + 0) % 5 / 5)
                        let x1 = ((x + 1) % 5 / 5) > 0 ? ((x + 1) % 5 / 5) : 1
                        let y1 = ((y + 1) % 5 / 5) > 0 ? ((y + 1) % 5 / 5) : 1

                        let v0 = WaterVertex(
                            position: [(x + 0) * 2, WATER_LEVEL, (y + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )
                        let v1 = WaterVertex(
                            position: [(x + 1) * 2, WATER_LEVEL, (y + 0) * 2],
                            textureCoordinate: [x1, y0]
                        )
                        let v2 = WaterVertex(
                            position: [(x + 1) * 2, WATER_LEVEL, (y + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v3 = WaterVertex(
                            position: [(x + 1) * 2, WATER_LEVEL, (y + 1) * 2],
                            textureCoordinate: [x1, y1]
                        )
                        let v4 = WaterVertex(
                            position: [(x + 0) * 2, WATER_LEVEL, (y + 1) * 2],
                            textureCoordinate: [x0, y1]
                        )
                        let v5 = WaterVertex(
                            position: [(x + 0) * 2, WATER_LEVEL, (y + 0) * 2],
                            textureCoordinate: [x0, y0]
                        )

                        water += [v0, v1, v2, v3, v4, v5]
                    }
                }

                // Check tile front
                if (cell_a.tile_front > -1) && (y + 1 < height) {
                    let tile = tiles[Int(cell_a.tile_front)]

                    let cell_b = surfaces[ _x + (_y + 1) * _width ]
                    let h_b    = cell_b.height
                    let l = lightmap_atlas(Int(tile.light))

                    let v0 = GroundVertex(
                        position: [(x+0)*2, h_b[0], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u3, tile.v3],
                        lightmapCoordinate: [l.u1, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v1 = GroundVertex(
                        position: [(x+1)*2, h_a[3], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u2, tile.v2],
                        lightmapCoordinate: [l.u2, l.v1],
                        tileColorCoordinate: [0, 0]
                    )
                    let v2 = GroundVertex(
                        position: [(x+1)*2, h_b[1], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u4, tile.v4],
                        lightmapCoordinate: [l.u2, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v3 = GroundVertex(
                        position: [(x+0)*2, h_b[0], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u3, tile.v3],
                        lightmapCoordinate: [l.u1, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v4 = GroundVertex(
                        position: [(x+1)*2, h_a[3], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u2, tile.v2],
                        lightmapCoordinate: [l.u2, l.v1],
                        tileColorCoordinate: [0, 0]
                    )
                    let v5 = GroundVertex(
                        position: [(x+0)*2, h_a[2], (y+1)*2],
                        normal: [0.0, 0.0, 1.0],
                        textureCoordinate: [tile.u1, tile.v1],
                        lightmapCoordinate: [l.u1, l.v1],
                        tileColorCoordinate: [0, 0]
                    )

                    mesh += [v0, v1, v2, v3, v4, v5]
                }


                // Check tile right
                if (cell_a.tile_right > -1) && (x + 1 < width) {
                    let tile = tiles[Int(cell_a.tile_right)]

                    let cell_b = surfaces[ (_x+1) + _y * _width ]
                    let h_b    = cell_b.height
                    let l = lightmap_atlas(Int(tile.light))

                    let v0 = GroundVertex(
                        position: [(x+1)*2, h_a[1], (y+0)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u2, tile.v2],
                        lightmapCoordinate: [l.u2, l.v1],
                        tileColorCoordinate: [0, 0]
                    )
                    let v1 = GroundVertex(
                        position: [(x+1)*2, h_a[3], (y+1)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u1, tile.v1],
                        lightmapCoordinate: [l.u1, l.v1],
                        tileColorCoordinate: [0, 0]
                    )
                    let v2 = GroundVertex(
                        position: [(x+1)*2, h_b[0], (y+0)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u4, tile.v4],
                        lightmapCoordinate: [l.u2, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v3 = GroundVertex(
                        position: [(x+1)*2, h_b[0], (y+0)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u4, tile.v4],
                        lightmapCoordinate: [l.u2, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v4 = GroundVertex(
                        position: [(x+1)*2, h_b[2], (y+1)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u3, tile.v3],
                        lightmapCoordinate: [l.u1, l.v2],
                        tileColorCoordinate: [0, 0]
                    )
                    let v5 = GroundVertex(
                        position: [(x+1)*2, h_a[3], (y+1)*2],
                        normal: [1.0, 0.0, 0.0],
                        textureCoordinate: [tile.u1, tile.v1],
                        lightmapCoordinate: [l.u1, l.v1],
                        tileColorCoordinate: [0, 0]
                    )

                    mesh += [v0, v1, v2, v3, v4, v5]
                }

            }
        }

        return (mesh: mesh, waterMesh: water)

//        // Return mesh informations
//        return {
//            width:           this.width,
//            height:          this.height,
//            textures:        this.textures,
//
//            lightmap:        lightmap,
//            lightmapSize:    this.lightmap.count,
//            tileColor:       this.createTilesColorImage(),
//            shadowMap:       this.createShadowmapData(),
//
//            mesh:            new Float32Array(mesh),
//            meshVertCount:   mesh.length/12,
//
//            waterMesh:       new Float32Array(water),
//            waterVertCount:  water.length/5
//        };
    }
}
