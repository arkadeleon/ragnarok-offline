//
//  SPRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import SwiftUI
import ROFileFormats
import ROFileSystem
import ROGraphics

enum SPRFilePreviewError: Error {
    case invalidSPRFile
}

struct SPRFilePreviewView: View {
    struct SpriteSection {
        var spriteSize: CGSize
        var sprites: [Sprite]
    }

    struct Sprite {
        var index: Int
        var image: StillImage
    }

    let file: File

    @State private var status: AsyncContentStatus<SpriteSection> = .notYetLoaded

    var body: some View {
        AsyncContentView(status: status) { section in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: section.spriteSize.width), spacing: 16)], spacing: 32) {
                    ForEach(section.sprites, id: \.index) { sprite in
                        Image(sprite.image.image, scale: 1, label: Text(""))
                            .frame(width: section.spriteSize.width, height: section.spriteSize.height)
                            .contextMenu {
                                ShareLink(
                                    item: sprite.image.named(String(format: "%@.%03d.png", file.name, sprite.index)),
                                    preview: SharePreview(file.name, image: Image(sprite.image.image, scale: 1, label: Text("")))
                                )
                            }
                    }
                }
                .padding(32)
            }
        }
        .task {
            await loadSPRFile()
        }
    }

    private func loadSPRFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard let data = file.contents() else {
            status = .failed(SPRFilePreviewError.invalidSPRFile)
            return
        }

        guard let spr = try? SPR(data: data) else {
            status = .failed(SPRFilePreviewError.invalidSPRFile)
            return
        }

        let images = (0..<spr.sprites.count).compactMap { index in
            spr.image(forSpriteAt: index)
        }

        let size = images.reduce(CGSize(width: 80, height: 80)) { size, image in
            CGSize(
                width: max(size.width, CGFloat(image.image.width)),
                height: max(size.height, CGFloat(image.image.height))
            )
        }

        let sprites = images.enumerated().map { (index, image) in
            Sprite(index: index, image: image)
        }

        let section = SpriteSection(spriteSize: size, sprites: sprites)
        status = .loaded(section)
    }
}

//#Preview {
//    SPRFilePreviewView(file: <#T##File#>)
//}