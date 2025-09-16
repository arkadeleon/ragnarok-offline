//
//  MTKTextureLoader+BMP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/16.
//

import ImageRendering
import MetalKit

extension MTKTextureLoader {
    public func newTexture(bmpData: Data) -> (any MTLTexture)? {
        guard let image = CGImageCreateWithData(bmpData)?.removingMagentaPixels() else {
            return nil
        }

        let texture = try? newTexture(cgImage: image, options: nil)
        return texture
    }
}
