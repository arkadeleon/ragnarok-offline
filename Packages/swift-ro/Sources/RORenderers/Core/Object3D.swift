//
//  Model3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//

import Metal

public class Object3D {
    public let meshes: [Mesh]

    public init(meshes: [Mesh]) {
        self.meshes = meshes
    }
}
