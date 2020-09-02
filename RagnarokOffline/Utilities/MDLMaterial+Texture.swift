//
//  MDLMaterial+Texture.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/9/2.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ModelIO

extension MDLMaterial {

    convenience init(textureName: String, textureData: Data) {
        let scatteringFunction = MDLScatteringFunction()
        self.init(name: textureName, scatteringFunction: scatteringFunction)

        let textureSampler = MDLTextureSampler()
        textureSampler.texture = MDLTexture(name: textureName, data: textureData)

        let baseColorProperty = MDLMaterialProperty(name: textureName, semantic: .baseColor, textureSampler: textureSampler)
        setProperty(baseColorProperty)
    }
}
