//
//  CGImage+PNG.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

extension CGImage {
    public func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, self, nil)
        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
