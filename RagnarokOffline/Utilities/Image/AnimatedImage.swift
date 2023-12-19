//
//  AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct AnimatedImage: Hashable {
    var images: [CGImage]
    var delay: CGFloat

    var size: CGSize {
        images.reduce(CGSize.zero) { size, image in
            CGSize(
                width: max(size.width, CGFloat(image.width)),
                height: max(size.height, CGFloat(image.height))
            )
        }
    }

    func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, images.count, nil) else {
            return nil
        }

        let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: 1]]
        CGImageDestinationSetProperties(imageDestination, properties as CFDictionary)

        for image in images {
            let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: delay]]
            CGImageDestinationAddImage(imageDestination, image, properties as CFDictionary)
        }

        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
