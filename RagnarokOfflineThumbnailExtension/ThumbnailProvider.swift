//
//  ThumbnailProvider.swift
//  RagnarokOfflineThumbnailExtension
//
//  Created by Leon Li on 2025/6/27.
//

import AVFoundation
import BinaryIO
import FileFormats
import QuickLookThumbnailing

enum ThumbnailProviderError: Error {
    case unsupportedFileFormat
    case generationFailed
}

class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, (any Error)?) -> Void) {
        do {
            let thumbnail = try thumbnail(for: request)
            let thumbnailSize = CGSize(width: thumbnail.width, height: thumbnail.height)
            let maximumThumbnailSize = AVMakeRect(aspectRatio: thumbnailSize, insideRect: CGRect(origin: .zero, size: request.maximumSize)).size
            let reply = QLThumbnailReply(contextSize: maximumThumbnailSize) { context in
                let rect = CGRect(x: 0, y: 0, width: context.width, height: context.height)
                context.draw(thumbnail, in: rect)
                return true
            }
            handler(reply, nil)
        } catch {
            handler(nil, error)
        }
    }

    private func thumbnail(for request: QLFileThumbnailRequest) throws -> CGImage {
        let pathExtension = request.fileURL.pathExtension.lowercased()
        switch pathExtension {
        case "gat":
            let data = try Data(contentsOf: request.fileURL)
            let gat = try GAT(data: data)

            if let thumbnail = gat.image() {
                return thumbnail
            } else {
                throw ThumbnailProviderError.generationFailed
            }
        case "pal":
            let data = try Data(contentsOf: request.fileURL)
            let pal = try PAL(data: data)

            let size = CGSize(width: 32 * request.scale, height: 32 * request.scale)
            if let thumbnail = pal.image(at: size) {
                return thumbnail
            } else {
                throw ThumbnailProviderError.generationFailed
            }
        case "spr":
            guard let decoder = BinaryDecoder(url: request.fileURL) else {
                throw ThumbnailProviderError.generationFailed
            }

            let spr = try decoder.decode(SPR.self)
            if let thumbnail = spr.imageForSprite(at: 0) {
                return thumbnail
            } else {
                throw ThumbnailProviderError.generationFailed
            }
        default:
            throw ThumbnailProviderError.unsupportedFileFormat
        }
    }
}
