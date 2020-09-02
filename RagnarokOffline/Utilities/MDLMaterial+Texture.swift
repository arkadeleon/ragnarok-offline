//
//  MDLMaterial+Texture.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/9/2.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ModelIO

extension MDLMaterial {

    convenience init(name: String, textureData: Data) {
        let scatteringFunction = MDLScatteringFunction()
        self.init(name: name, scatteringFunction: scatteringFunction)

        let textureSampler = MDLTextureSampler()
        textureSampler.texture = MDLTexture(name: name, data: textureData)

        let property = MDLMaterialProperty(name: name, semantic: .baseColor, textureSampler: textureSampler)
        setProperty(property)
    }
}
