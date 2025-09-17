//
//  ResourceManager+Image.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/16.
//

import CoreGraphics
import ImageRendering
import ResourceManagement

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        var image = CGImageCreateWithData(data)
        if removesMagentaPixels {
            image = image?.removingMagentaPixels()
        }

        if let image {
            return image
        } else {
            throw ImageResourceError.cannotCreateImage
        }
    }
}
