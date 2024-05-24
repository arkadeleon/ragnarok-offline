//
//  MTKTextureLoader+BMP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/16.
//

import MetalKit
import ROGraphics

extension MTKTextureLoader {
    public func newTexture(bmpData: Data) -> MTLTexture? {
        guard let image = CGImageCreateWithData(bmpData)?.removingMagentaPixels() else {
            return nil
        }

        let texture = try? newTexture(cgImage: image, options: nil)
        return texture
    }
}
