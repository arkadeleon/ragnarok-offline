//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileGridCell: View {
    var file: File

    @State private var subtitleKey: LocalizedStringKey?

    var body: some View {
        ImageGridCell(title: file.name) {
            if let subtitleKey {
                Text(subtitleKey)
            }
        } image: {
            FileThumbnailView(file: file)
        }
        .task {
            await loadSubtitle()
        }
    }

    private func loadSubtitle() async {
        if file.isDirectory {
            let fileCount = await file.fileCount()
            subtitleKey = LocalizedStringKey("^[\(fileCount) item](inflect: true)")
        } else {
            let fileSize = await file.size()
            let formatStyle = FloatingPointFormatStyle<Float>().precision(.significantDigits(2))
            if fileSize > 1024 * 1024 * 1024 {
                let fileSizeInGB = Float(fileSize) / 1024 / 1024 / 1024
                subtitleKey = LocalizedStringKey("\(fileSizeInGB.formatted(formatStyle)) GB")
            } else if fileSize > 1024 * 1024 {
                let fileSizeInMB = Float(fileSize) / 1024 / 1024
                subtitleKey = LocalizedStringKey("\(fileSizeInMB.formatted(formatStyle)) MB")
            } else if fileSize > 1024 {
                let fileSizeInKB = Float(fileSize) / 1024
                subtitleKey = LocalizedStringKey("\(fileSizeInKB.formatted(formatStyle)) KB")
            } else {
                subtitleKey = LocalizedStringKey("\(fileSize.formatted()) B")
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
