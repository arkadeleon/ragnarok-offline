//
//  DocumentThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import DataCompression
import ImageIO
import UIKit

enum DocumentThumbnailRepresentation {
    case icon(name: String)
    case thumbnail(image: CGImage)
}

class DocumentThumbnailGenerator {

    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.document-thumbnail-generator")

    func generateThumbnail(for document: DocumentWrapper, update updateHandler: @escaping (DocumentThumbnailRepresentation) -> Void) {
        if document.isDirectory {
            updateHandler(.icon(name: "folder.fill"))
            return
        }

        if document.isArchive {
            updateHandler(.icon(name: "doc.zipper"))
            return
        }

        switch document.contentType {
        case .txt, .xml, .ini, .lua, .lub:
            updateHandler(.icon(name: "doc.text"))
        case .bmp, .png, .jpg, .tga:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = document.contents() else {
                    return
                }

                guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                    return
                }

                let scale = UIScreen.main.scale
                let options: [CFString : Any] = [
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceThumbnailMaxPixelSize: 40 * scale
                ]
                guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                    return
                }

                updateHandler(.thumbnail(image: thumbnail))
            }
        case .ebm:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = document.contents(), let decompressedData = data.unzip() else {
                    return
                }

                guard let imageSource = CGImageSourceCreateWithData(decompressedData as CFData, nil) else {
                    return
                }

                let options = [
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceShouldCacheImmediately: true
                ]
                guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                    return
                }

                updateHandler(.thumbnail(image: thumbnail))
            }
        case .pal:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = document.contents() else {
                    return
                }

                guard let palette = try? Palette(data: data) else {
                    return
                }

                let scale = UIScreen.main.scale
                guard let image = palette.image(at: CGSize(width: 32 * scale, height: 32 * scale)) else {
                    return
                }

                updateHandler(.thumbnail(image: image))
            }
        case .mp3, .wav:
            updateHandler(.icon(name: "waveform.circle"))
        case .spr:
            updateHandler(.icon(name: "photo.stack"))

            queue.async {
                guard let data = document.contents() else {
                    return
                }

                guard let spr = try? SPRDocument(data: data) else {
                    return
                }

                guard let image = spr.imageForSprite(at: 0) else {
                    return
                }

                updateHandler(.thumbnail(image: image.image))
            }
        case .act:
            updateHandler(.icon(name: "livephoto"))

            queue.async {
                guard case .grfEntry(let tree, let path) = document else {
                    return
                }

                let sprPath = (path as NSString).deletingPathExtension.appending(".spr")
                guard let sprData = try? tree.contentsOfEntry(withName: sprPath) else {
                    return
                }

                guard let spr = try? SPRDocument(data: sprData) else {
                    return
                }

                guard let image = spr.imageForSprite(at: 0) else {
                    return
                }

                updateHandler(.thumbnail(image: image.image))
            }
        case .rsm:
            updateHandler(.icon(name: "square.stack.3d.up"))
        case .rsw:
            updateHandler(.icon(name: "map"))
        default:
            updateHandler(.icon(name: "doc"))
        }
    }
}
