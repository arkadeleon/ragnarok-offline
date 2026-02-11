//
//  ImageResource.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/2/11.
//

import CoreGraphics
import ImageRendering

enum ImageResourceError: Error {
    case cannotCreateImage
}

extension Resources {
    final public class Image: Resource {
        public let cgImage: CGImage

        init(cgImage: CGImage) {
            self.cgImage = cgImage
        }
    }
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> Resources.Image {
        let resourceIdentifier = "\(path)+removesMagentaPixels:\(removesMagentaPixels)"
        return try await imageResourceCache.resource(forIdentifier: resourceIdentifier) { [self] in
            let data = try await self.contentsOfResource(at: path)

            guard let cgImage = CGImageCreateWithData(data) else {
                throw ImageResourceError.cannotCreateImage
            }

            if removesMagentaPixels {
                return Resources.Image(cgImage: cgImage.removingMagentaPixels() ?? cgImage)
            } else {
                return Resources.Image(cgImage: cgImage)
            }
        }
    }
}
