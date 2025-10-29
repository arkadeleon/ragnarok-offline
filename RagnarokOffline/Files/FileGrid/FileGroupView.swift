//
//  FileGroupView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/6.
//

import SwiftUI

struct FileGroupView: View {
    var group: FileGroup

    @State private var files: [File] = []

    var body: some View {
        ImageGrid(files) { file in
            NavigationLink(value: file) {
                FileGridCell(file: file)
            }
            .fileContextMenu(file: file)
        }
        .navigationTitle(group.name)
        .toolbarTitleDisplayMode(.inline)
        .task {
            files = await group.files()
        }
    }
}

#Preview {
    AsyncContentView {
        try await File.previewGND()
    } content: { file in
        FileGroupView(group: FileGroup(file: file, type: .references))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
