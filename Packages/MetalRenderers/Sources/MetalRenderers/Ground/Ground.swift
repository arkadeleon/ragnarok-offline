//
//  Ground.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//

import FileFormats
import MetalShaders
import SGLMath
import simd

public struct GroundMesh {
    public var vertices: [GroundVertex] = []
    public var textureName: String
}

public struct Ground {
    public var width: Int
    public var height: Int
    public var altitude: Float

    public var meshes: [GroundMesh] = []

    public init(gat: GAT, gnd: GND) {
        width = Int(gat.width)
        height = Int(gat.height)
        altitude = gat.tileAt(x: width / 2, y: height / 2).averageAltitude

        meshes = gnd.textures.map { textureName in
            let mesh = GroundMesh(textureName: textureName)
            return mesh
        }

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        let normals = getSmoothNormal(gnd: gnd)

        let l_count_w  = roundf(sqrtf(Float(gnd.lightmap.count)))
        let l_count_h  = ceilf(sqrtf(Float(gnd.lightmap.count)))
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
                let cube = gnd.cubes[x + y * width]

                // Check top surface
                if cube.topSurfaceIndex > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurfaceIndex)]

                    // Check if has texture
                    if surface.textureIndex > -1 {
                        let n = normals[x + y * width]
                        let l = lightmap_atlas(Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[0],
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[1],
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[2],
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[3],
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )

                        meshes[Int(surface.textureIndex)].vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }

                // Check front surface
                if cube.frontSurfaceIndex > -1 && y + 1 < height {
                    let surface = gnd.surfaces[Int(cube.frontSurfaceIndex)]

                    if surface.textureIndex > -1 {
                        let frontCube = gnd.cubes[x + (y + 1) * width]
                        let l = lightmap_atlas(Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, frontCube.bottomRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, frontCube.bottomLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )

                        meshes[Int(surface.textureIndex)].vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }

                // Check right surface
                if cube.rightSurfaceIndex > -1 && x + 1 < width {
                    let surface = gnd.surfaces[Int(cube.rightSurfaceIndex)]

                    if surface.textureIndex > -1 {
                        let rightCube = gnd.cubes[(x + 1) + y * width]
                        let l = lightmap_atlas(Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )

                        meshes[Int(surface.textureIndex)].vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }
            }
        }
    }

    private struct LightmapAtlas {
        var u1: Float
        var u2: Float
        var v1: Float
        var v2: Float
    }

    private func createLightmapImage(gnd: GND) -> [UInt8] {
        let count     = Int(gnd.lightmap.count)
        let data      = gnd.lightmap.data
        let per_cell  = Int(gnd.lightmap.per_cell)

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

    private func createTilesColorImage(gnd: GND) -> [UInt8] {
        let width = Int(gnd.width)
        let height = Int(gnd.height)
        var data: [UInt8] = Array(repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]
                if cube.topSurfaceIndex > -1 {
                    let index = (x + y * width) * 4
                    let color = gnd.surfaces[Int(cube.topSurfaceIndex)].color
                    data[index + 0] = color.alpha
                    data[index + 1] = color.red
                    data[index + 2] = color.green
                    data[index + 3] = color.blue
                }
            }
        }

        return data
    }

    private func createShadowmapData(gnd: GND) -> [UInt8] {
        let width = Int(gnd.width)
        let height = Int(gnd.height)

        var out: [UInt8] = Array(repeating: 0, count: (width * 8) * (height * 8))

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                if cube.topSurfaceIndex > -1 {
                    let topSurface = Int(cube.topSurfaceIndex)
                    let light = Int(gnd.surfaces[topSurface].lightmapIndex)
                    let per_cell = Int(gnd.lightmap.per_cell)
                    let index = light * 4 * per_cell

                    for i in 0..<8 {
                        for j in 0..<8 {
                            out[(x * 8 + i) + (y * 8 + j) * (width * 8)] = gnd.lightmap.data[index + i + j * 8]
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

    private func getSmoothNormal(gnd: GND) -> [[SIMD3<Float>]] {
        let width = Int(gnd.width)
        let height = Int(gnd.height)

        let count = width * height
        var tmp: [SIMD3<Float>] = Array(repeating: SIMD3<Float>(), count: count)

        let vec_in_tmp: ((Int) -> SIMD3<Float>) = { i -> SIMD3<Float> in
            if i >= 0 && i < tmp.count {
                return tmp[i]
            } else {
                return SIMD3<Float>()
            }
        }

        let normal = Array(repeating: SIMD3<Float>(), count: 4)
        var normals = Array(repeating: normal, count: count)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[Int(x + y * width)]

                if cube.topSurfaceIndex > -1 /*&& surfaces[Int(cube.topSurface)].textureIndex > -1*/ {
                    let a: SIMD3<Float> = [
                        (Float(x) + 0) * 2,
                        cube.bottomLeftAltitude / 5,
                        (Float(y) + 0) * 2
                    ]
                    let b: SIMD3<Float> = [
                        (Float(x) + 1) * 2,
                        cube.bottomRightAltitude / 5,
                        (Float(y) + 0) * 2
                    ]
                    let c: SIMD3<Float> = [
                        (Float(x) + 1) * 2,
                        cube.topLeftAltitude / 5,
                        (Float(y) + 1) * 2
                    ]
                    let d: SIMD3<Float> = [
                        (Float(x) + 0) * 2,
                        cube.topRightAltitude / 5,
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
}
