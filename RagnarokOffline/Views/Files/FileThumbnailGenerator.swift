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
        if file.isDirectory {
            updateHandler(.icon(name: "folder.fill"))
            return
        }

        if file.isArchive {
            updateHandler(.icon(name: "doc.zipper"))
            return
        }

        switch file.contentType {
        case .txt, .xml, .ini, .lua, .lub:
            updateHandler(.icon(name: "doc.text"))
        case .bmp, .png, .jpg, .tga:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = file.contents() else {
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
        case .ebm:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = file.contents(), let decompressedData = data.unzip() else {
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

                updateHandler(.thumbnail(image: UIImage(cgImage: thumbnail)))
            }
        case .pal:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = file.contents() else {
                    return
                }

                guard let palette = try? Palette(data: data) else {
                    return
                }

                let scale = UIScreen.main.scale
                guard let image = palette.image(at: CGSize(width: 32 * scale, height: 32 * scale)) else {
                    return
                }

                updateHandler(.thumbnail(image: UIImage(cgImage: image)))
            }
        case .mp3, .wav:
            updateHandler(.icon(name: "waveform.circle"))
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
        case .rsm:
            updateHandler(.icon(name: "square.stack.3d.up"))
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
        case .rsw:
            updateHandler(.icon(name: "map"))
        default:
            updateHandler(.icon(name: "doc"))
        }
    }
}