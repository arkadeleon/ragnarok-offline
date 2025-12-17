//
//  ResourceManager+Image.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/9/16.
//

import CoreGraphics
import ImageRendering

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        guard let image = CGImageCreateWithData(data) else {
            throw ImageResourceError.cannotCreateImage
        }

        if removesMagentaPixels {
            return image.removingMagentaPixels() ?? image
        } else {
            return image
        }
    }
}
