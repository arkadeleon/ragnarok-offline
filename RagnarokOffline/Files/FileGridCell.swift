//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileGridCell: View {
    var file: ObservableFile

    @State private var subtitle: String?

    var body: some View {
        ImageGridCell(title: file.file.name, subtitle: subtitle) {
            FileThumbnailView(file: file)
        }
        .task {
            await loadSubtitle()
        }
    }

    nonisolated private func loadSubtitle() async {
        let fileType = await file.file.info.type
        switch fileType {
        case .directory:
            let fileCount = await file.file.files().count
            await MainActor.run {
                subtitle = fileCount.formatted() + " item(s)"
            }
        default:
            let fileSize = await file.file.info.size
            await MainActor.run {
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
}

#Preview {
    FileGridCell(file: .previewGAT)
}
