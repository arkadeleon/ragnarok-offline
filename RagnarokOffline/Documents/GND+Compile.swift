//
//  GND+Compile.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics
import UIKit

extension GND {
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
                let cell = cubes[x + y * width]
                if cell.tileUp > -1 {
                    let index = (x + y * width) * 4
                    let color = tiles[Int(cell.tileUp)].color
                    data[index + 0] = color.alpha
                    data[index + 1] = color.red
                    data[index + 2] = color.green
                    data[index + 3] = color.blue
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
                let cell = cubes[x + y * width]

                if cell.tileUp > -1 {
                    let tile_up = Int(cell.tileUp)
                    let light = Int(tiles[tile_up].lightmapIndex)
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

    private func getSmoothNormal() -> [[simd_float3]] {
        let width = Int(width)
        let height = Int(height)

        let count = width * height
        var tmp: [simd_float3] = Array(repeating: simd_float3(), count: count)

        let vec_in_tmp: ((Int) -> simd_float3) = { i -> simd_float3 in
            if i >= 0 && i < tmp.count {
                return tmp[i]
            } else {
                return simd_float3()
            }
        }

        let normal = Array(repeating: simd_float3(), count: 4)
        var normals = Array(repeating: normal, count: count)

        for y in 0..<height {
            for x in 0..<width {
                let cell = cubes[Int(x + y * width)]

                if cell.tileUp > -1 /*&& tiles[Int(cell.tileUp)].textureIndex > -1*/ {
                    let a: simd_float3 = [
                        (Float(x) + 0) * 2,
                        cell.bottomLeft / 5,
                        (Float(y) + 0) * 2
                    ]
                    let b: simd_float3 = [
                        (Float(x) + 1) * 2,
                        cell.bottomRight / 5,
                        (Float(y) + 0) * 2
                    ]
                    let c: simd_float3 = [
                        (Float(x) + 1) * 2,
                        cell.topLeft / 5,
                        (Float(y) + 1) * 2
                    ]
                    let d: simd_float3 = [
                        (Float(x) + 0) * 2,
                        cell.topRight / 5,
                        (Float(y) + 1) * 2
                    ]
                    tmp[x + y * width] = calcNormal(a, b, c, d)
                }
            }
        }

        for y in 0..<height {
            for x in 0..<width {
                var n = normals[x + y * width]

                // Up left
                n[0] = n[0] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[0] = n[0] + vec_in_tmp((x - 1) + (y + 0) * width)
                n[0] = n[0] + vec_in_tmp((x - 1) + (y - 1) * width)
                n[0] = n[0] + vec_in_tmp((x + 0) + (y - 1) * width)
                n[0] = simd_normalize(n[0])

                // Up right
                n[1] = n[1] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[1] = n[1] + vec_in_tmp((x + 1) + (y + 0) * width)
                n[1] = n[1] + vec_in_tmp((x + 1) + (y - 1) * width)
                n[1] = n[1] + vec_in_tmp((x + 0) + (y - 1) * width)
                n[1] = simd_normalize(n[1])

                // Bottom right
                n[2] = n[2] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[2] = n[2] + vec_in_tmp((x + 1) + (y + 0) * width)
                n[2] = n[2] + vec_in_tmp((x + 1) + (y + 1) * width)
                n[2] = n[2] + vec_in_tmp((x + 0) + (y + 1) * width)
                n[2] = simd_normalize(n[2])

                // Bottom left
                n[3] = n[3] + vec_in_tmp((x + 0) + (y + 0) * width)
                n[3] = n[3] + vec_in_tmp((x - 1) + (y + 0) * width)
                n[3] = n[3] + vec_in_tmp((x - 1) + (y + 1) * width)
                n[3] = n[3] + vec_in_tmp((x + 0) + (y + 1) * width)
                n[3] = simd_normalize(n[3])

                normals[x + y * width] = n
            }
        }

        return normals
    }

    func compile(waterLevel: Float, waterHeight: Float, textureProvider: (String) -> MTLTexture?) -> (groundMeshes: [GroundMesh], waterVertices: [WaterVertex]) {
        let width = Int(width)
        let height = Int(height)

        let normals = getSmoothNormal()

        var groundMeshes: [GroundMesh] = textures.map { texture in
            GroundMesh(texture: textureProvider(texture))
        }

        var waterVertices: [WaterVertex] = []

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

        // Compiling mesh
        for y in 0..<height {
            for x in 0..<width {
                let cell_a = cubes[x + y * width]
                let h_a = [
                    cell_a.bottomLeft / 5,
                    cell_a.bottomRight / 5,
                    cell_a.topLeft / 5,
                    cell_a.topRight / 5
                ]

                // Check tile up
                if cell_a.tileUp > -1 {
                    let tile = tiles[Int(cell_a.tileUp)]

                    // Check if has texture
                    if tile.textureIndex > -1 {
                        let n = normals[x + y * width]
                        let l = lightmap_atlas(Int(tile.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, h_a[0], (Float(y) + 0) * 2],
                            normal: [n[0][0], n[0][1], n[0][1]],
                            textureCoordinate: [tile.u1, tile.v1],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, h_a[1], (Float(y) + 0) * 2],
                            normal: [n[1][0], n[1][1], n[1][1]],
                            textureCoordinate: [tile.u2, tile.v2],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, h_a[3], (Float(y) + 1) * 2],
                            normal: [n[2][0], n[2][1], n[2][1]],
                            textureCoordinate: [tile.u4, tile.v4],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 1) * 2, h_a[3], (Float(y) + 1) * 2],
                            normal: [n[2][0], n[2][1], n[2][1]],
                            textureCoordinate: [tile.u4, tile.v4],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )
                        let v4 = GroundVertex(
                            position: [(Float(x) + 0) * 2, h_a[2], (Float(y) + 1) * 2],
                            normal: [n[3][0], n[3][1], n[3][1]],
                            textureCoordinate: [tile.u3, tile.v3],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )
                        let v5 = GroundVertex(
                            position: [(Float(x) + 0) * 2, h_a[0], (Float(y) + 0) * 2],
                            normal: [n[0][0], n[0][1], n[0][1]],
                            textureCoordinate: [tile.u1, tile.v1],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )

                        groundMeshes[Int(tile.textureIndex)].vertices += [v0, v1, v2, v3, v4, v5]

                        // Add water only if it's upper than the ground.
                        if h_a[0] > waterLevel - waterHeight ||
                            h_a[1] > waterLevel - waterHeight ||
                            h_a[2] > waterLevel - waterHeight ||
                            h_a[3] > waterLevel - waterHeight {

                            let x0 = ((Float(x) + 0).truncatingRemainder(dividingBy: 5) / 5)
                            let y0 = ((Float(y) + 0).truncatingRemainder(dividingBy: 5) / 5)
                            let x1 = ((Float(x) + 1).truncatingRemainder(dividingBy: 5) / 5) > 0 ? ((Float(x) + 1).truncatingRemainder(dividingBy: 5) / 5) : 1
                            let y1 = ((Float(y) + 1).truncatingRemainder(dividingBy: 5) / 5) > 0 ? ((Float(y) + 1).truncatingRemainder(dividingBy: 5) / 5) : 1

                            let v0 = WaterVertex(
                                position: [(Float(x) + 0) * 2, waterLevel, (Float(y) + 0) * 2],
                                textureCoordinate: [x0, y0]
                            )
                            let v1 = WaterVertex(
                                position: [(Float(x) + 1) * 2, waterLevel, (Float(y) + 0) * 2],
                                textureCoordinate: [x1, y0]
                            )
                            let v2 = WaterVertex(
                                position: [(Float(x) + 1) * 2, waterLevel, (Float(y) + 1) * 2],
                                textureCoordinate: [x1, y1]
                            )
                            let v3 = WaterVertex(
                                position: [(Float(x) + 1) * 2, waterLevel, (Float(y) + 1) * 2],
                                textureCoordinate: [x1, y1]
                            )
                            let v4 = WaterVertex(
                                position: [(Float(x) + 0) * 2, waterLevel, (Float(y) + 1) * 2],
                                textureCoordinate: [x0, y1]
                            )
                            let v5 = WaterVertex(
                                position: [(Float(x) + 0) * 2, waterLevel, (Float(y) + 0) * 2],
                                textureCoordinate: [x0, y0]
                            )

                            waterVertices += [v0, v1, v2, v3, v4, v5]
                        }
                    }
                }

                // Check tile front
                if (cell_a.tileFront > -1) && (y + 1 < height) {
                    let tile = tiles[Int(cell_a.tileFront)]

                    if tile.textureIndex > -1 {
                        let cell_b = cubes[x + (y + 1) * width]
                        let h_b = [
                            cell_b.bottomLeft / 5,
                            cell_b.bottomRight / 5,
                            cell_b.topLeft / 5,
                            cell_b.topRight / 5
                        ]
                        let l = lightmap_atlas(Int(tile.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x)+0)*2, h_b[0], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u3, tile.v3],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x)+1)*2, h_a[3], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u2, tile.v2],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x)+1)*2, h_b[1], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u4, tile.v4],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x)+0)*2, h_b[0], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u3, tile.v3],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v4 = GroundVertex(
                            position: [(Float(x)+1)*2, h_a[3], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u2, tile.v2],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v5 = GroundVertex(
                            position: [(Float(x)+0)*2, h_a[2], (Float(y)+1)*2],
                            normal: [0.0, 0.0, 1.0],
                            textureCoordinate: [tile.u1, tile.v1],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )

                        groundMeshes[Int(tile.textureIndex)].vertices += [v0, v1, v2, v3, v4, v5]
                    }
                }

                // Check tile right
                if (cell_a.tileRight > -1) && (x + 1 < width) {
                    let tile = tiles[Int(cell_a.tileRight)]

                    if tile.textureIndex > -1 {
                        let cell_b = cubes[(x + 1) + y * width]
                        let h_b = [
                            cell_b.bottomLeft / 5,
                            cell_b.bottomRight / 5,
                            cell_b.topLeft / 5,
                            cell_b.topRight / 5
                        ]
                        let l = lightmap_atlas(Int(tile.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x)+1)*2, h_a[1], (Float(y)+0)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u2, tile.v2],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x)+1)*2, h_a[3], (Float(y)+1)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u1, tile.v1],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x)+1)*2, h_b[0], (Float(y)+0)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u4, tile.v4],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x)+1)*2, h_b[0], (Float(y)+0)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u4, tile.v4],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v4 = GroundVertex(
                            position: [(Float(x)+1)*2, h_b[2], (Float(y)+1)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u3, tile.v3],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v5 = GroundVertex(
                            position: [(Float(x)+1)*2, h_a[3], (Float(y)+1)*2],
                            normal: [1.0, 0.0, 0.0],
                            textureCoordinate: [tile.u1, tile.v1],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )

                        groundMeshes[Int(tile.textureIndex)].vertices += [v0, v1, v2, v3, v4, v5]
                    }
                }
            }
        }

        return (groundMeshes, waterVertices)
    }
}
