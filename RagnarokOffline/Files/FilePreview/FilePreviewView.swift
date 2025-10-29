//
//  FilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import SwiftUI

struct FilePreviewView: View {
    var file: File

    var body: some View {
        Group {
            switch file.utType {
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
                GNDFilePreviewView(file: file)
            case .rsm:
                RSMFilePreviewView(file: file)
            case .rsw:
                RSWFilePreviewView(file: file)
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
        FilePreviewView(file: file)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
