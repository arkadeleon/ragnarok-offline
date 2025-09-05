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
        AsyncContentView {
            try await loadACTFile()
        } content: { sections in
            ScrollView {
                ForEach(sections, id: \.index) { section in
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: section.actionSize.width), spacing: 16)], spacing: 32) {
                        ForEach(section.actions, id: \.index) { action in
                            AnimatedImageView(animatedImage: action.animatedImage)
                                .frame(width: section.actionSize.width, height: section.actionSize.height)
                                .contextMenu {
                                    AnimatedImageShareLink(
                                        animatedImage: action.animatedImage,
                                        filename: String(format: "%@.%03d", file.name, action.index)
                                    )
                                }
                        }
                    }
                    .padding(32)
                }
            }
        }
    }

    private func loadACTFile() async throws -> [ActionSection] {
        let actData = try await file.contents()

        let sprData: Data
        switch file.node {
        case .regularFile(let url):
            let sprURL = url.deletingPathExtension().appendingPathExtension("spr")
            sprData = try Data(contentsOf: sprURL)
        case .grfArchiveEntry(let grfArchive, let entry):
            let sprPath = entry.path.replacingExtension("spr")
            sprData = try await grfArchive.contentsOfEntry(at: sprPath)
        default:
            throw FileError.fileIsDirectory
        }

        let act = try ACT(data: actData)
        let spr = try SPR(data: sprData)

        let sprite = SpriteResource(act: act, spr: spr)
        let spriteRenderer = SpriteRenderer()

        var animatedImages: [AnimatedImage] = []
        for actionIndex in 0..<act.actions.count {
            let animation = await spriteRenderer.render(sprite: sprite, actionIndex: actionIndex)
            let animatedImage = AnimatedImage(animation: animation)
            animatedImages.append(animatedImage)
        }

        if animatedImages.count % 8 != 0 {
            let minimumSize = CGSize(width: 80, height: 80)
            let size = animatedImages.reduce(minimumSize) { size, animatedImage in
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
                let minimumSize = CGSize(width: 80, height: 80)
                let size = animatedImages.reduce(minimumSize) { size, animatedImage in
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
    AsyncContentView {
        try await File.previewACT()
    } content: { file in
        ACTFilePreviewView(file: file)
    }
    .frame(width: 400, height: 300)
}
