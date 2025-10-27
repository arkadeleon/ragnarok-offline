//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//

import DataCompression
import RagnarokFileFormats
import Foundation
import ImageIO

enum FileThumbnailError: Error {
    case unsupportedFileFormat
    case cannotCreateImageSource
    case cannotCreateThumbnail
    case cannotCreateImage
}

final class FileThumbnailGenerator: Sendable {
    func generateThumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail {
        guard let utType = request.file.utType else {
            throw FileThumbnailError.unsupportedFileFormat
        }

        switch utType {
        case let utType where utType.conforms(to: .image):
            let data = try await request.file.contents()

            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                throw FileThumbnailError.cannotCreateImageSource
            }

            let options: [CFString : Any] = [
                kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: 40 * request.scale
            ]
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                throw FileThumbnailError.cannotCreateThumbnail
            }

            return FileThumbnail(cgImage: thumbnail)
        case .ebm:
            let data = try await request.file.contents()

            let decompressor = GzipDecompressor()
            let decompressedData = try await decompressor.unzip(data: data)

            guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil) else {
                throw FileThumbnailError.cannotCreateImageSource
            }

            guard let thumbnail = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw FileThumbnailError.cannotCreateImage
            }

            return FileThumbnail(cgImage: thumbnail)
        case .gat:
            let data = try await request.file.contents()
            let gat = try GAT(data: data)

            guard let image = gat.image() else {
                throw FileThumbnailError.cannotCreateImage
            }

            return FileThumbnail(cgImage: image)
        case .pal:
            let data = try await request.file.contents()
            let pal = try PAL(data: data)

            let size = CGSize(width: 32 * request.scale, height: 32 * request.scale)
            guard let image = pal.image(at: size) else {
                throw FileThumbnailError.cannotCreateImage
            }

            return FileThumbnail(cgImage: image)
        case .spr:
            let data = try await request.file.contents()
            let spr = try SPR(data: data)

            guard let image = spr.imageForSprite(at: 0) else {
                throw FileThumbnailError.cannotCreateImage
            }

            return FileThumbnail(cgImage: image)
        default:
            throw FileThumbnailError.unsupportedFileFormat
        }
    }
}
