//
//  Ground.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2023/11/27.
//

import RagnarokFileFormats
import RagnarokShaders
import SGLMath
import simd

public struct GroundMesh {
    public var vertices: [GroundVertex] = []
}

public struct Ground {
    public var width: Int
    public var height: Int
    public var altitude: Float

    public var mesh: GroundMesh
    public var textureAtlas: GroundTextureAtlas
    public var lightmapAtlas: GroundLightmapAtlas
    public var tileColorMap: GroundTileColorMap

    public init(gat: GAT, gnd: GND) {
        width = Int(gat.width)
        height = Int(gat.height)
        altitude = gat.tileAt(x: width / 2, y: height / 2).averageAltitude

        mesh = GroundMesh()
        textureAtlas = GroundTextureAtlas(gnd: gnd)
        lightmapAtlas = GroundLightmapAtlas(lightmap: gnd.lightmap)
        tileColorMap = GroundTileColorMap(gnd: gnd)

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        let normals = getSmoothNormal(gnd: gnd)

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
                        let uv = textureAtlas.uv(for: surface)
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[0],
                            textureCoordinate: [uv.u[0], uv.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[1],
                            textureCoordinate: [uv.u[1], uv.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 0.5) / Float(height)]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[2],
                            textureCoordinate: [uv.u[3], uv.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [(Float(x) + 1.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[3],
                            textureCoordinate: [uv.u[2], uv.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [(Float(x) + 0.5) / Float(width), (Float(y) + 1.5) / Float(height)]
                        )

                        mesh.vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }

                // Check front surface
                if cube.frontSurfaceIndex > -1 && y + 1 < height {
                    let surface = gnd.surfaces[Int(cube.frontSurfaceIndex)]

                    if surface.textureIndex > -1 {
                        let frontCube = gnd.cubes[x + (y + 1) * width]
                        let uv = textureAtlas.uv(for: surface)
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [uv.u[0], uv.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [uv.u[1], uv.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, frontCube.bottomRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [uv.u[3], uv.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, frontCube.bottomLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [0, 0, 1],
                            textureCoordinate: [uv.u[2], uv.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )

                        mesh.vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }

                // Check right surface
                if cube.rightSurfaceIndex > -1 && x + 1 < width {
                    let surface = gnd.surfaces[Int(cube.rightSurfaceIndex)]

                    if surface.textureIndex > -1 {
                        let rightCube = gnd.cubes[(x + 1) + y * width]
                        let uv = textureAtlas.uv(for: surface)
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [uv.u[0], uv.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [uv.u[1], uv.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            tileColorCoordinate: [0, 0]
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [uv.u[3], uv.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            tileColorCoordinate: [0, 0]
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: [1, 0, 0],
                            textureCoordinate: [uv.u[2], uv.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            tileColorCoordinate: [0, 0]
                        )

                        mesh.vertices += [v0, v1, v2, v2, v3, v0]
                    }
                }
            }
        }
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
