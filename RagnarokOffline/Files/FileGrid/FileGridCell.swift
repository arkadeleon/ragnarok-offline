//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileGridCell: View {
    var file: File

    @State private var subtitle: String?

    var body: some View {
        ImageGridCell(title: file.name) {
            if let subtitle {
                Text(subtitle)
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
            subtitle = String(localized: LocalizedStringResource("^[\(fileCount) item](inflect: true)"))
        } else {
            let fileSize = await file.size()
            subtitle = fileSize.formatted(.byteCount(style: .file))
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
