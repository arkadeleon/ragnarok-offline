//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//

import DataCompression
import Foundation
import ImageIO
import ROCore
import ROFileFormats

class FileThumbnailGenerator {
    func generateThumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail? {
        guard let utType = request.file.utType else {
            return nil
        }

        switch utType {
        case let utType where utType.conforms(to: .image):
            guard let data = await request.file.contents() else {
                return nil
            }

            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
            }

            let options: [CFString : Any] = [
                kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: 40 * request.scale
            ]
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                return nil
            }

            return FileThumbnail(cgImage: thumbnail)
        case .ebm:
            guard let data = await request.file.contents()?.unzip() else {
                return nil
            }

            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
            }

            guard let thumbnail = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                return nil
            }

            return FileThumbnail(cgImage: thumbnail)
        case .gat:
            guard let data = await request.file.contents() else {
                return nil
            }

            let gat = try GAT(data: data)

            guard let image = gat.image() else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .pal:
            guard let data = await request.file.contents() else {
                return nil
            }

            let pal = try PAL(data: data)

            guard let image = pal.image(at: CGSize(width: 32 * request.scale, height: 32 * request.scale)) else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .spr:
            guard let data = await request.file.contents() else {
                return nil
            }

            let spr = try SPR(data: data)

            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        default:
            return nil
        }
    }
}
