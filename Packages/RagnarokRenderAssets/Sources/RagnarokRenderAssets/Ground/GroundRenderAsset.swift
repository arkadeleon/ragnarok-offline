//
//  GroundRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import RagnarokCore
import RagnarokFileFormats
import RagnarokShaders
import simd

public struct GroundMesh {
    public var vertices: [GroundVertex]
    public var textureName: String
}

public struct GroundRenderAsset {
    public var width: Int
    public var height: Int
    public var altitude: Float

    public var meshes: [GroundMesh]
    public var textureImages: [String : CGImage]

    public var lightmapAtlas: GroundLightmapAtlas
    public var lightmapTextureImage: CGImage?

    public init(gat: GAT, gnd: GND, textureImages: [String : CGImage]) {
        width = Int(gat.width)
        height = Int(gat.height)
        altitude = gat.tileAt(x: width / 2, y: height / 2).averageAltitude

        meshes = []
        self.textureImages = textureImages

        lightmapAtlas = GroundLightmapAtlas(lightmap: gnd.lightmap)
        lightmapTextureImage = lightmapAtlas.makeCGImage()

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        let normals = calculateNormals(gnd: gnd)

        var verticesByTextureIndex: [Int : [GroundVertex]] = [:]

        // Compile the mesh once so render backends can consume the same asset.
        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]

                if cube.topSurfaceIndex > -1 {
                    let surface = gnd.surfaces[Int(cube.topSurfaceIndex)]
                    let textureIndex = Int(surface.textureIndex)

                    if textureIndex > -1 {
                        let n = normals[x + y * width]
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[0],
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            color: topSurfaceColor(in: gnd, x: x, y: y) ?? .zero
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: n[1],
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y) ?? .zero
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[2],
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y + 1) ?? .zero
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: n[3],
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            color: topSurfaceColor(in: gnd, x: x, y: y + 1) ?? .zero
                        )

                        verticesByTextureIndex[textureIndex, default: []] += [v0, v1, v2, v2, v3, v0]
                    }
                }

                if cube.frontSurfaceIndex > -1 && y + 1 < height {
                    let surface = gnd.surfaces[Int(cube.frontSurfaceIndex)]
                    let textureIndex = Int(surface.textureIndex)

                    if textureIndex > -1 {
                        let frontCube = gnd.cubes[x + (y + 1) * width]
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let normal: SIMD3<Float> = cube.topLeftAltitude < frontCube.bottomLeftAltitude ? [0, 0, 1] : [0, 0, -1]

                        let v0 = GroundVertex(
                            position: [(Float(x) + 0) * 2, cube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            color: topSurfaceColor(in: gnd, x: x, y: y + 1) ?? .one
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y + 1) ?? .one
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, frontCube.bottomRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y + 1) ?? .one
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 0) * 2, frontCube.bottomLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            color: topSurfaceColor(in: gnd, x: x, y: y + 1) ?? .one
                        )

                        verticesByTextureIndex[textureIndex, default: []] += [v0, v1, v2, v2, v3, v0]
                    }
                }

                if cube.rightSurfaceIndex > -1 && x + 1 < width {
                    let surface = gnd.surfaces[Int(cube.rightSurfaceIndex)]
                    let textureIndex = Int(surface.textureIndex)

                    if textureIndex > -1 {
                        let rightCube = gnd.cubes[(x + 1) + y * width]
                        let l = lightmapAtlas.uv(forLightmapSliceIndex: Int(surface.lightmapIndex))

                        let normal: SIMD3<Float> = cube.topLeftAltitude < rightCube.bottomLeftAltitude ? [1, 0, 0] : [-1, 0, 0]

                        let v0 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.topRightAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[0], surface.v[0]],
                            lightmapCoordinate: [l.u1, l.v1],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y + 1) ?? .one
                        )
                        let v1 = GroundVertex(
                            position: [(Float(x) + 1) * 2, cube.bottomRightAltitude / 5, (Float(y) + 0) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[1], surface.v[1]],
                            lightmapCoordinate: [l.u2, l.v1],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y) ?? .one
                        )
                        let v2 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.bottomLeftAltitude / 5, (Float(y) + 0) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[3], surface.v[3]],
                            lightmapCoordinate: [l.u2, l.v2],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y) ?? .one
                        )
                        let v3 = GroundVertex(
                            position: [(Float(x) + 1) * 2, rightCube.topLeftAltitude / 5, (Float(y) + 1) * 2],
                            normal: normal,
                            textureCoordinate: [surface.u[2], surface.v[2]],
                            lightmapCoordinate: [l.u1, l.v2],
                            color: topSurfaceColor(in: gnd, x: x + 1, y: y + 1) ?? .one
                        )

                        verticesByTextureIndex[textureIndex, default: []] += [v0, v1, v2, v2, v3, v0]
                    }
                }
            }
        }

        meshes = gnd.textures.enumerated().map { textureIndex, textureName in
            GroundMesh(vertices: verticesByTextureIndex[textureIndex] ?? [], textureName: textureName)
        }
    }

    private func topSurfaceColor(in gnd: GND, x: Int, y: Int) -> SIMD3<Float>? {
        let width = Int(gnd.width)
        let height = Int(gnd.height)

        guard x < width && y < height else {
            return .one
        }

        let cube = gnd.cubes[x + y * width]
        guard cube.topSurfaceIndex > -1 else {
            return nil
        }

        let color = gnd.surfaces[Int(cube.topSurfaceIndex)].color
        return [Float(color.red), Float(color.green), Float(color.blue)] / 255
    }

    private func calculateNormals(gnd: GND) -> [[SIMD3<Float>]] {
        let width = Int(gnd.width)
        let height = Int(gnd.height)

        let count = width * height
        var defaultNormals = Array(repeating: Array(repeating: SIMD3<Float>(), count: 4), count: count)
        var sharedNormals = Array(repeating: Array(repeating: SIMD3<Float>(), count: 4), count: count)

        for index in 0..<count {
            let cube = gnd.cubes[index]
            let v1 = SIMD3<Float>(0, cube.bottomLeftAltitude, 0)
            let v2 = SIMD3<Float>(10, cube.bottomRightAltitude, 0)
            let v3 = SIMD3<Float>(0, cube.topLeftAltitude, 10)
            let v4 = SIMD3<Float>(10, cube.topRightAltitude, 10)

            let normal1 = simd_normalize(simd_cross(v2 - v1, v3 - v1))
            let normal2 = simd_normalize(simd_cross(v3 - v4, v2 - v4))
            let normal = normal1 + normal2

            defaultNormals[index] = [normal1, normal, normal, normal1]
            sharedNormals[index] = [normal1, normal, normal, normal2]
        }

        let altitudes: (GND.Cube) -> [Float] = { cube in
            [cube.bottomLeftAltitude, cube.bottomRightAltitude, cube.topLeftAltitude, cube.topRightAltitude]
        }

        var normals = defaultNormals

        for y in 0..<height {
            for x in 0..<width {
                let index = x + y * width
                let cubeAltitudes = altitudes(gnd.cubes[index])

                for corner in 0..<4 {
                    var normal = defaultNormals[index][corner]

                    for neighbor in 1..<4 {
                        let nx = x + (neighbor % 2) * (corner % 2 == 0 ? -1 : 1)
                        let ny = y + (neighbor / 2) * (corner < 2 ? -1 : 1)
                        guard nx >= 0 && nx < width && ny >= 0 && ny < height else {
                            continue
                        }

                        let neighborCorner = (corner + neighbor * (1 - 2 * (corner & 1))) & 3
                        let neighborIndex = nx + ny * width
                        guard altitudes(gnd.cubes[neighborIndex])[neighborCorner] == cubeAltitudes[corner] else {
                            continue
                        }

                        normal += sharedNormals[neighborIndex][neighborCorner]
                    }

                    normals[index][corner] = simd_normalize(normal)
                }
            }
        }

        return normals.map { [$0[0], $0[1], $0[3], $0[2]] }
    }
}
