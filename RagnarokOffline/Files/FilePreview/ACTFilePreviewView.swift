//
//  ACTFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import ROCore
import ROFileFormats
import RORendering
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

    var file: File

    var body: some View {
        AsyncContentView(load: loadACTFile) { sections in
            ScrollView {
                ForEach(sections, id: \.index) { section in
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: section.actionSize.width), spacing: 16)], spacing: 32) {
                        ForEach(section.actions, id: \.index) { action in
                            AnimatedImageView(animatedImage: action.animatedImage)
                                .frame(width: section.actionSize.width, height: section.actionSize.height)
                                .contextMenu {
                                    AnimatedImageShareLink(
                                        animatedImage: action.animatedImage,
                                        filename: String(format: "%@.%03d.png", file.name, action.index)
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
        guard let actData = await file.contents() else {
            throw FilePreviewError.invalidACTFile
        }

        let sprData: Data
        switch file.node {
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

        let sprite = SpriteResource(act: act, spr: spr)
        let spriteRenderer = SpriteRenderer(sprites: [sprite])

        var animatedImages: [AnimatedImage] = []
        for actionIndex in 0..<act.actions.count {
            let result = await spriteRenderer.renderAction(at: actionIndex, headDirection: .straight)
            let animatedImage = AnimatedImage(
                frames: result.frames,
                frameWidth: result.frameWidth,
                frameHeight: result.frameHeight,
                frameInterval: result.frameInterval,
                frameScale: spriteRenderer.scale
            )
            animatedImages.append(animatedImage)
        }

        if animatedImages.count % 8 != 0 {
            let size = animatedImages.reduce(CGSize(width: 80, height: 80)) { size, animatedImage in
                CGSize(
                    width: max(size.width, animatedImage.frameWidth),
                    height: max(size.height, animatedImage.frameHeight)
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
                        width: max(size.width, animatedImage.frameWidth),
                        height: max(size.height, animatedImage.frameHeight)
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
    ACTFilePreviewView(file: .previewACT)
}
