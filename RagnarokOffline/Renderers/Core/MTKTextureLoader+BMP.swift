//
//  MTKTextureLoader+BMP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import MetalKit

extension MTKTextureLoader {
    func newTexture(bmpData: Data) -> MTLTexture? {
        guard let cgImage = UIImage(bmpData: bmpData)?.cgImage else {
            return nil
        }

        let texture = try? newTexture(cgImage: cgImage, options: nil)
        return texture
    }
}
