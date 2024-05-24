//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//

import ImageIO
import Foundation
import DataCompression
import ROFileFormats
import ROGraphics

class FileThumbnailGenerator {
    static let shared = FileThumbnailGenerator()

    func generateThumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail? {
        guard let type = request.file.type else {
            return nil
        }

        switch type {
        case let type where type.conforms(to: .image) || type == .ebm:
            let data: Data?
            if type == .ebm {
                data = request.file.contents()?.unzip()
            } else {
                data = request.file.contents()
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
                kCGImageSourceThumbnailMaxPixelSize: 40 * request.scale
            ]
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                return nil
            }

            return FileThumbnail(cgImage: thumbnail)
        case .gat:
            guard let data = request.file.contents() else {
                return nil
            }

            let gat = try GAT(data: data)

            guard let image = gat.image() else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .pal:
            guard let data = request.file.contents() else {
                return nil
            }

            let pal = try PAL(data: data)

            guard let image = pal.image(at: CGSize(width: 32 * request.scale, height: 32 * request.scale)) else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .spr:
            guard let data = request.file.contents() else {
                return nil
            }

            let spr = try SPR(data: data)

            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }

            return FileThumbnail(cgImage: image.image)
        default:
            return nil
        }
    }
}
