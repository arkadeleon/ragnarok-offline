//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileGridCell: View {
    var file: ObservableFile

    var body: some View {
        ImageGridCell(title: file.file.name, subtitle: file.file.info.size.formatted() + " B") {
            FileThumbnailView(file: file)
        }
    }
}

#Preview {
    FileGridCell(file: PreviewFiles.gatFile)
}
