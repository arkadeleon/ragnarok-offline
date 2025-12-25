//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileGridCell: View {
    var file: File

    @State private var subtitle = ""

    var body: some View {
        ImageGridCell(title: file.name, reservesSubtitleSpace: true, subtitle: subtitle) {
            FileThumbnailView(file: file)
        }
        .task {
            await loadSubtitle()
        }
    }

    private func loadSubtitle() async {
        if file.isDirectory {
            let fileCount = await file.fileCount()
            if fileCount == 1 {
                subtitle = fileCount.formatted() + " item"
            } else {
                subtitle = fileCount.formatted() + " items"
            }
        } else {
            let fileSize = await file.size()
            let formatStyle = FloatingPointFormatStyle<Float>().precision(.significantDigits(2))
            if fileSize > 1024 * 1024 * 1024 {
                let fileSizeInGB = Float(fileSize) / 1024 / 1024 / 1024
                subtitle = fileSizeInGB.formatted(formatStyle) + " GB"
            } else if fileSize > 1024 * 1024 {
                let fileSizeInMB = Float(fileSize) / 1024 / 1024
                subtitle = fileSizeInMB.formatted(formatStyle) + " MB"
            } else if fileSize > 1024 {
                let fileSizeInKB = Float(fileSize) / 1024
                subtitle = fileSizeInKB.formatted(formatStyle) + " KB"
            } else {
                subtitle = fileSize.formatted() + " B"
            }
        }
    }
}

#Preview {
    AsyncContentView {
        try await [
            File.previewFolder(),
            File.previewGRF(),
            File.previewGAT(),
            File.previewWideGAT(),
            File.previewTallGAT(),
            File.previewGND(),
            File.previewRSW(),
            File.previewSPR(),
        ]
    } content: { files in
        ScrollView(.horizontal) {
            HStack {
                ForEach(files) { file in
                    FileGridCell(file: file)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
