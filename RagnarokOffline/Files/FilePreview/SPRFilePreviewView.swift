//
//  SPRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import SwiftUI

struct SPRFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case sprites
        case tree
    }

    @State private var viewMode: ViewMode = .sprites

    var body: some View {
        Group {
            switch viewMode {
            case .sprites:
                SPRFileSpritesView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("Sprites", systemImage: "square.grid.2x2")
                        .tag(ViewMode.sprites)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct SPRFileSpritesView: View {
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
        AsyncContentView {
            try await loadSPRFile()
        } content: { section in
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

    private func loadSPRFile() async throws -> SpriteSection {
        let data = try await file.contents()
        let spr = try SPR(data: data)

        let images = (0..<spr.sprites.count).compactMap { index in
            spr.imageForSprite(at: index)
        }

        let minimumSize = CGSize(width: 80, height: 80)
        let size = images.reduce(minimumSize) { size, image in
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
    AsyncContentView {
        try await File.previewSPR()
    } content: { file in
        SPRFilePreviewView(file: file)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
