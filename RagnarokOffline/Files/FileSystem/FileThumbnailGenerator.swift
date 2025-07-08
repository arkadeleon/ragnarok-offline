//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//

import Foundation
import ImageIO
import ROCore
import ROFileFormats
import SwiftGzip

class FileThumbnailGenerator {
    func generateThumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail? {
        guard let utType = request.file.utType else {
            return nil
        }

        switch utType {
        case let utType where utType.conforms(to: .image):
            let data = try await request.file.contents()

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
            let data = try await request.file.contents()

            let decompressor = GzipDecompressor()
            let decompressedData = try await decompressor.unzip(data: data)

            guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil) else {
                return nil
            }

            guard let thumbnail = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                return nil
            }

            return FileThumbnail(cgImage: thumbnail)
        case .gat:
            let data = try await request.file.contents()
            let gat = try GAT(data: data)

            guard let image = gat.image() else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .pal:
            let data = try await request.file.contents()
            let pal = try PAL(data: data)

            let size = CGSize(width: 32 * request.scale, height: 32 * request.scale)
            guard let image = pal.image(at: size) else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        case .spr:
            let data = try await request.file.contents()
            let spr = try SPR(data: data)

            guard let image = spr.imageForSprite(at: 0) else {
                return nil
            }

            return FileThumbnail(cgImage: image)
        default:
            return nil
        }
    }
}
