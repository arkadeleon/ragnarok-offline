//
//  FilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import RagnarokResources
import SwiftUI

struct FilePreviewView: View {
    var file: File
    var resourceManager: ResourceManager

    var body: some View {
        Group {
            switch file.utType {
            case let utType where utType.identifier ==  "net.daringfireball.markdown":
                MarkdownFilePreviewView(file: file)
            case let utType where utType.conforms(to: .text):
                TextFilePreviewView(file: file)
            case .lua, .lub:
                TextFilePreviewView(file: file)
            case let utType where utType.conforms(to: .image):
                ImageFilePreviewView(file: file)
            case .ebm, .pal:
                ImageFilePreviewView(file: file)
            case let utType where utType.conforms(to: .audio):
                AudioFilePreviewView(file: file)
            case .act:
                ACTFilePreviewView(file: file)
            case .gat:
                GATFilePreviewView(file: file)
            case .gnd:
                GNDFilePreviewView(file: file, resourceManager: resourceManager)
            case .imf:
                FileJSONViewer(file: file)
            case .rsm, .rsm2:
                RSMFilePreviewView(file: file, resourceManager: resourceManager)
            case .rsw:
                RSWFilePreviewView(file: file, resourceManager: resourceManager)
            case .spr:
                SPRFilePreviewView(file: file)
            case .str:
                STRFilePreviewView(file: file)
            default:
                ContentUnavailableView("Unsupported File", systemImage: "doc")
            }
        }
        .navigationTitle(file.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                ShareLink(item: file, preview: SharePreview(file.name))
            }
        }
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSW()
    } content: { file in
        FilePreviewView(file: file, resourceManager: .previewing)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
