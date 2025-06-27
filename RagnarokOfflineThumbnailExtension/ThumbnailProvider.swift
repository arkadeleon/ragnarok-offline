//
//  ThumbnailProvider.swift
//  RagnarokOfflineThumbnailExtension
//
//  Created by Leon Li on 2025/6/27.
//

import AVFoundation
import BinaryIO
import QuickLookThumbnailing
import ROFileFormats

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
