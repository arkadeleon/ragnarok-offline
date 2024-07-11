//
//  FileCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/27.
//

import SwiftUI

struct FileCell: View {
    var file: ObservableFile

    var body: some View {
        VStack {
            FileThumbnailView(file: file)

            ZStack(alignment: .top) {
                // This VStack is just for reserving space.
                VStack(spacing: 2) {
                    Text(" ")
                        .lineLimit(2, reservesSpace: true)
                        .font(.body)

                    Text(" ")
                        .lineLimit(1, reservesSpace: true)
                        .font(.footnote)
                }

                VStack(spacing: 2) {
                    Text(file.file.name)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .lineLimit(2, reservesSpace: false)
                        .foregroundStyle(.primary)
                        .font(.body)

                    Text(file.file.info.size.formatted() + " B")
                        .frame(maxWidth: .infinity)
                        .lineLimit(1, reservesSpace: false)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    FileCell(file: PreviewFiles.gatFile)
}
