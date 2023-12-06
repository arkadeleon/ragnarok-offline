//
//  Model3D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal

class Object3D {
    let meshes: [Mesh]

    init(meshes: [Mesh]) {
        self.meshes = meshes
    }
}
