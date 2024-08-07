//
//  ACTFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import ROCore
import ROFileFormats
import SwiftUI

struct ACTFilePreviewView: View {
    struct ActionSection {
        var index: Int
        var actionSize: CGSize
        var actions: [Action]
    }

    struct Action {
        var index: Int
        var animatedImage: AnimatedImage
    }

    var file: ObservableFile

    var body: some View {
        AsyncContentView(load: loadACTFile) { sections in
            ScrollView {
                ForEach(sections, id: \.index) { section in
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: section.actionSize.width), spacing: 16)], spacing: 32) {
                        ForEach(section.actions, id: \.index) { action in
                            AnimatedImageView(animatedImage: action.animatedImage)
                                .frame(width: section.actionSize.width, height: section.actionSize.height)
                                .contextMenu {
                                    ShareLink(
                                        item: TransferableAnimatedImage(name: String(format: "%@.%03d.png", file.file.name, action.index), image: action.animatedImage),
                                        preview: SharePreview(file.file.name, image: Image(action.animatedImage.images[0], scale: 1, label: Text("")))
                                    )
                                }
                        }
                    }
                    .padding(32)
                }
            }
        }
    }

    nonisolated private func loadACTFile() async throws -> [ActionSection] {
        guard let actData = file.file.contents() else {
            throw FilePreviewError.invalidACTFile
        }

        let sprData: Data
        switch file.file {
        case .regularFile(let url):
            let sprPath = url.deletingPathExtension().path().appending(".spr")
            sprData = try Data(contentsOf: URL(filePath: sprPath))
        case .grfEntry(let grf, let path):
            let sprPath = path.replacingExtension("spr")
            sprData = try grf.contentsOfEntry(at: sprPath)
        default:
            throw FilePreviewError.invalidACTFile
        }

        let act = try ACT(data: actData)
        let spr = try SPR(data: sprData)

        let sprites = spr.sprites.enumerated()
        let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
        let imagesForSpritesByType = spritesByType.mapValues { sprites in
            sprites.map { sprite in
                spr.image(forSpriteAt: sprite.offset)
            }
        }

        var animatedImages: [AnimatedImage] = []
        for index in 0..<act.actions.count {
            let animatedImage = act.animatedImage(forActionAt: index, imagesForSpritesByType: imagesForSpritesByType)
            animatedImages.append(animatedImage)
        }

        if animatedImages.count % 8 != 0 {
            let size = animatedImages.reduce(CGSize(width: 80, height: 80)) { size, animatedImage in
                CGSize(
                    width: max(size.width, CGFloat(animatedImage.size.width)),
                    height: max(size.height, CGFloat(animatedImage.size.height))
                )
            }
            let actions = animatedImages.enumerated().map { (index, animatedImage) in
                Action(index: index, animatedImage: animatedImage)
            }
            let actionSection = ActionSection(index: 0, actionSize: size, actions: actions)
            return [actionSection]
        } else {
            let sectionCount = animatedImages.count / 8
            let actionSections = (0..<sectionCount).map { sectionIndex in
                let startIndex = sectionIndex * 8
                let endIndex = (sectionIndex + 1) * 8
                let animatedImages = Array(animatedImages[startIndex..<endIndex])
                let size = animatedImages.reduce(CGSize(width: 80, height: 80)) { size, animatedImage in
                    CGSize(
                        width: max(size.width, CGFloat(animatedImage.size.width)),
                        height: max(size.height, CGFloat(animatedImage.size.height))
                    )
                }
                let actions = animatedImages.enumerated().map { (index, animatedImage) in
                    Action(index: startIndex + index, animatedImage: animatedImage)
                }
                let actionSection = ActionSection(index: sectionIndex, actionSize: size, actions: actions)
                return actionSection
            }
            return actionSections
        }
    }
}

#Preview {
    ACTFilePreviewView(file: PreviewFiles.actFile)
}
