//
//  FileGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI
import ROFileSystem

struct FileGridCell: View {
    let file: File

    var body: some View {
        VStack {
            FileThumbnailView(file: file)

            Text(file.name)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2, reservesSpace: true)
        }
    }
}
