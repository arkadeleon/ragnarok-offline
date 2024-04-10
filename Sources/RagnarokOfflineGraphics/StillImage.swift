//
//  StillImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public struct StillImage: Hashable {
    public var image: CGImage

    public func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, image, nil)
        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
