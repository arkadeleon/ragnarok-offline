//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import ImageIO
import Foundation
import DataCompression

class FileThumbnailGenerator {
    func generateThumbnail(for file: File, scale: CGFloat) -> CGImage? {
        guard let type = file.type else {
            return nil
        }

        switch type {
        case let type where type.conforms(to: .image) || type == .ebm:
            let data: Data?
            if type == .ebm {
                data = file.contents()?.unzip()
            } else {
                data = file.contents()
            }

            guard let data else {
                return nil
            }

            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
            }

            let options: [CFString : Any] = [
                kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: 40 * scale
            ]
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                return nil
            }

            return thumbnail
        case .gat:
            guard let data = file.contents() else {
                return nil
            }

            guard let gat = try? GAT(data: data) else {
                return nil
            }

            return gat.image()
        case .pal:
            guard let data = file.contents() else {
                return nil
            }

            guard let pal = try? PAL(data: data) else {
                return nil
            }

            guard let image = pal.image(at: CGSize(width: 32 * scale, height: 32 * scale)) else {
                return nil
            }

            return image
        case .spr:
            guard let data = file.contents() else {
                return nil
            }

            guard let spr = try? SPR(data: data) else {
                return nil
            }

            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }

            return image.image
        default:
            return nil
        }
    }
}
