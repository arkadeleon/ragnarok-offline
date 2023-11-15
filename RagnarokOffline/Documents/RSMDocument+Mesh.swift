//
//  RSMDocument+Mesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/27.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ModelIO

struct RSMVertex {

    var position: simd_float3
    var textureCoordinate: simd_float2
}

struct RSMFaceElement: Equatable {

    var vertexIndex: UInt16
    var textureVertexIndex: UInt16
}

extension MDLAsset {

    convenience init(document: RSMDocument, materials: [MDLMaterial?]) {
        self.init(bufferAllocator: nil)

        if let rootNode = document.mainNode {
            let mesh = MDLMesh(node: rootNode, materials: materials)
            add(mesh)
        }
    }
}

extension MDLMesh {

    convenience init(node: RSMNode, materials: [MDLMaterial?]) {
        var elements: [RSMFaceElement] = []
        let indexOfElement = { (element: RSMFaceElement) -> UInt16 in
            if let index = elements.firstIndex(of: element) {
                return UInt16(index)
            } else {
                elements.append(element)
                let index = elements.count - 1
                return UInt16(index)
            }
        }

        var indexBuffers = Array(repeating: [UInt16](), count: node.textures.count)

        for face in node.faces {
            let textureIndex = Int(face.texid)
            guard textureIndex < indexBuffers.count else {
                continue
            }

            let element0 = RSMFaceElement(vertexIndex: face.vertidx[0], textureVertexIndex: face.tvertidx[0])
            let element1 = RSMFaceElement(vertexIndex: face.vertidx[1], textureVertexIndex: face.tvertidx[1])
            let element2 = RSMFaceElement(vertexIndex: face.vertidx[2], textureVertexIndex: face.tvertidx[2])

            indexBuffers[textureIndex].append(indexOfElement(element0))
            indexBuffers[textureIndex].append(indexOfElement(element1))
            indexBuffers[textureIndex].append(indexOfElement(element2))
        }

        let allocator = MDLMeshBufferDataAllocator()

        let vertices = elements.map { (element) -> RSMVertex in
            let vertex = RSMVertex(
                position: node.vertices[Int(element.vertexIndex)],
                textureCoordinate: [node.tvertices[Int(element.textureVertexIndex) * 6 + 4], node.tvertices[Int(element.textureVertexIndex) * 6 + 5]]
            )
            return vertex
        }
        let vertexData = Data(bytes: vertices, count: MemoryLayout<RSMVertex>.stride * vertices.count)
        let vertexBuffer = allocator.newBuffer(with: vertexData, type: .vertex)

        let vertexDescriptor = MDLVertexDescriptor()

        let attribute0 = vertexDescriptor.attributes[0] as! MDLVertexAttribute
        attribute0.name = MDLVertexAttributePosition
        attribute0.format = .float3
        attribute0.offset = 0

        let attribute1 = vertexDescriptor.attributes[1] as! MDLVertexAttribute
        attribute1.name = MDLVertexAttributeTextureCoordinate
        attribute1.format = .float2
        attribute1.offset = 12

        let layout0 = vertexDescriptor.layouts[0] as! MDLVertexBufferLayout
        layout0.stride = MemoryLayout<RSMVertex>.stride

        let submeshes = indexBuffers.enumerated().map { (index, indexBuffer) -> MDLSubmesh in
            let data = Data(bytes: indexBuffer, count: MemoryLayout<UInt16>.size * indexBuffer.count)
            let meshBuffer = allocator.newBuffer(with: data, type: .index)
            let submesh = MDLSubmesh(indexBuffer: meshBuffer, indexCount: indexBuffer.count, indexType: .uInt16, geometryType: .triangles, material: nil)
            submesh.material = materials[Int(node.textures[index])]
            return submesh
        }

        self.init(vertexBuffer: vertexBuffer, vertexCount: vertices.count, descriptor: vertexDescriptor, submeshes: submeshes)

        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, node.pos)
        // TODO: rotate
        matrix = matrix_scale(matrix, node.scale)
        matrix = matrix * simd_float4x4(node.mat3)
        self.transform = MDLTransform(matrix: matrix)
    }
}
