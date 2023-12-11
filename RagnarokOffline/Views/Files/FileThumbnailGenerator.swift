//
//  FileThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import DataCompression
import ImageIO
import UIKit

enum FileThumbnailRepresentation {
    case icon(name: String)
    case thumbnail(image: UIImage)
}

class FileThumbnailGenerator {
    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.file-thumbnail-generator")

    func generateThumbnail(for file: File, update updateHandler: @escaping (FileThumbnailRepresentation) -> Void) {
        guard let type = file.type else {
            updateHandler(.icon(name: "doc"))
            return
        }

        if type.conforms(to: .directory) {
            updateHandler(.icon(name: "folder.fill"))
            return
        }

        if type.conforms(to: .archive) {
            updateHandler(.icon(name: "doc.zipper"))
            return
        }

        switch type {
        case let type where type.conforms(to: .text) || type == .lua || type == .lub:
            updateHandler(.icon(name: "doc.text"))
        case let type where type.conforms(to: .image) || type == .ebm:
            updateHandler(.icon(name: "photo"))

            queue.async {
                let data: Data?
                if type == .ebm {
                    data = file.contents()?.unzip()
                } else {
                    data = file.contents()
                }

                guard let data else {
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

                updateHandler(.thumbnail(image: UIImage(cgImage: thumbnail)))
            }
        case let type where type.conforms(to: .audio):
            updateHandler(.icon(name: "waveform.circle"))
        case .act:
            updateHandler(.icon(name: "livephoto"))

            queue.async {
                guard case .grfEntry(let grf, let entry) = file else {
                    return
                }

                let sprPath = entry.path.replacingExtension("spr")
                guard let sprData = try? grf.contentsOfEntry(at: sprPath) else {
                    return
                }

                guard let spr = try? SPR(data: sprData) else {
                    return
                }

                guard let image = spr.image(forSpriteAt: 0) else {
                    return
                }

                updateHandler(.thumbnail(image: UIImage(cgImage: image.image)))
            }
        case .gat:
            updateHandler(.icon(name: "square.grid.3x3.middle.filled"))

            queue.async {
                guard let data = file.contents() else {
                    return
                }

                guard let gat = try? GAT(data: data) else {
                    return
                }

                guard let image = gat.image() else {
                    return
                }

                updateHandler(.thumbnail(image: image))
            }
        case .pal:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = file.contents() else {
                    return
                }

                guard let pal = try? PAL(data: data) else {
                    return
                }

                let scale = UIScreen.main.scale
                guard let image = pal.image(at: CGSize(width: 32 * scale, height: 32 * scale)) else {
                    return
                }

                updateHandler(.thumbnail(image: UIImage(cgImage: image)))
            }
        case .rsm:
            updateHandler(.icon(name: "square.stack.3d.up"))
        case .rsw:
            updateHandler(.icon(name: "map"))
        case .spr:
            updateHandler(.icon(name: "photo.stack"))

            queue.async {
                guard let data = file.contents() else {
                    return
                }

                guard let spr = try? SPR(data: data) else {
                    return
                }

                guard let image = spr.image(forSpriteAt: 0) else {
                    return
                }

                updateHandler(.thumbnail(image: UIImage(cgImage: image.image)))
            }
        default:
            updateHandler(.icon(name: "doc"))
        }
    }
}
