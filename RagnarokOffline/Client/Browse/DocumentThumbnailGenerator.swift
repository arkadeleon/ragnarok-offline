//
//  DocumentThumbnailGenerator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
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
        case .bmp, .jpg, .tga, .pal:
            updateHandler(.icon(name: "photo"))

            queue.async {
                guard let data = document.contents() else {
                    return
                }

                guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                    return
                }

                let options = [
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceThumbnailMaxPixelSize: 40 * UIScreen.main.scale
                ]
                guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                    return
                }

                updateHandler(.thumbnail(image: thumbnail))
            }
        case .mp3, .wav:
            updateHandler(.icon(name: "waveform.circle"))
        case .spr:
            updateHandler(.icon(name: "photo"))
        case .act:
            updateHandler(.icon(name: "bolt"))
        case .rsm:
            updateHandler(.icon(name: "square.stack.3d.up"))
        case .rsw:
            updateHandler(.icon(name: "map"))
        default:
            updateHandler(.icon(name: "doc"))
        }
    }
}
