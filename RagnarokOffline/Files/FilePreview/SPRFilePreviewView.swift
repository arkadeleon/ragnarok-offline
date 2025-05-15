//
//  SPRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import ROCore
import ROFileFormats
import SwiftUI

struct SPRFilePreviewView: View {
    struct SpriteSection {
        var spriteSize: CGSize
        var sprites: [Sprite]
    }

    struct Sprite {
        var index: Int
        var image: CGImage
    }

    var file: File

    var body: some View {
        AsyncContentView(load: loadSPRFile) { section in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: section.spriteSize.width), spacing: 16)], spacing: 32) {
                    ForEach(section.sprites, id: \.index) { sprite in
                        Image(sprite.image, scale: 1, label: Text(verbatim: ""))
                            .frame(width: section.spriteSize.width, height: section.spriteSize.height)
                            .contextMenu {
                                ShareLink(
                                    item: TransferableImage(image: sprite.image, filename: String(format: "%@.%03d", file.name, sprite.index)),
                                    preview: SharePreview(file.name, image: Image(sprite.image, scale: 1, label: Text(verbatim: "")))
                                )
                            }
                    }
                }
                .padding(32)
            }
        }
    }

    nonisolated private func loadSPRFile() async throws -> SpriteSection {
        guard let data = await file.contents() else {
            throw FilePreviewError.invalidSPRFile
        }

        let spr = try SPR(data: data)

        let images = (0..<spr.sprites.count).compactMap { index in
            spr.imageForSprite(at: index)
        }

        let size = images.reduce(CGSize(width: 80, height: 80)) { size, image in
            CGSize(
                width: max(size.width, CGFloat(image.width)),
                height: max(size.height, CGFloat(image.height))
            )
        }

        let sprites = images.enumerated().map { (index, image) in
            Sprite(index: index, image: image)
        }

        let section = SpriteSection(spriteSize: size, sprites: sprites)
        return section
    }
}

#Preview {
    SPRFilePreviewView(file: .previewSPR)
}
