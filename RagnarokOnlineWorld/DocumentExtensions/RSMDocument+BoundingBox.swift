//
//  RSMDocument+BoundingBox.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/30.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

struct RSMBoundingBox {

    var max = Vector3<Float>(-.infinity, -.infinity, -.infinity)
    var min = Vector3<Float>(.infinity, .infinity, .infinity)
    var offset = Vector3<Float>()
    var range = Vector3<Float>()
    var center = Vector3<Float>()
}

extension RSMDocument {

    func calcBoundingBox() -> (RSMBoundingBox, [RSMNodeBoundingBoxWrapper]) {
        var box = RSMBoundingBox()

        let matrix = Matrix4x4<Float>()

        let wrappers = nodes.map(RSMNodeBoundingBoxWrapper.init)
        let mainWrapper = wrappers.first { $0.node.name == mainNode?.name }

        mainWrapper?.calcBoundingBox(matrix, wrappers: wrappers)

        for i in 0..<3 {
            for j in 0..<wrappers.count {
                box.max[i] = max(box.max[i], wrappers[j].box.max[i])
                box.min[i] = min(box.min[i], wrappers[j].box.min[i])
            }
            box.offset[i] = (box.max[i] + box.min[i]) / 2
            box.range[i] = (box.max[i] - box.min[i]) / 2
            box.center[i] = box.min[i] + box.range[i]
        }

        return (box, wrappers)
    }
}

class RSMNodeBoundingBoxWrapper {

    let node: RSMNode

    var box = RSMBoundingBox()
    var matrix = Matrix4x4<Float>()

    init(node: RSMNode) {
        self.node = node
    }

    func calcBoundingBox(_ _matrix: Matrix4x4<Float>, wrappers: [RSMNodeBoundingBoxWrapper]) {
        self.matrix = _matrix
        self.matrix =  SGLMath.translate(self.matrix, node.pos)

        if node.rotationKeyframes.count == 0 {
//            self.matrix = SGLMath.rotate(self.matrix, rotangle, rotaxis)
        } else {
            self.matrix = SGLMath.rotateQuat(self.matrix, w: node.rotationKeyframes[0].q)
        }

        self.matrix = SGLMath.scale(self.matrix, node.scale)

        var matrix = self.matrix

        if wrappers.count > 1 {
            matrix = SGLMath.translate(matrix, node.offset)
        }

        matrix = matrix * Matrix4x4(node.mat3)

        for i in 0..<node.vertices.count {
            let x = node.vertices[i][0]
            let y = node.vertices[i][1]
            let z = node.vertices[i][2]

            var v = Vector3<Float>()
            v[0] = matrix[0, 0] * x + matrix[1, 0] * y + matrix[2, 0] * z + matrix[3, 0]
            v[1] = matrix[0, 1] * x + matrix[1, 1] * y + matrix[2, 1] * z + matrix[3, 1]
            v[2] = matrix[0, 2] * x + matrix[1, 2] * y + matrix[2, 2] * z + matrix[3, 2]

            for j in 0..<3 {
                box.min[j] = min(v[j], box.min[j])
                box.max[j] = max(v[j], box.max[j])
            }
        }

        for i in 0..<3 {
            box.offset[i] = (box.max[i] + box.min[i]) / 2
            box.range[i] = (box.max[i] - box.min[i]) / 2
            box.center[i] = box.min[i] + box.range[i]
        }

        for wrapper in wrappers {
            if wrapper.node.parentname == node.name && node.name != node.parentname {
                wrapper.calcBoundingBox(self.matrix, wrappers: wrappers)
            }
        }
    }
}
