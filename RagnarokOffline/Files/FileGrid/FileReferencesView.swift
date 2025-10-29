//
//  FileReferencesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/6.
//

import SwiftUI

struct FileReferencesView: View {
    var file: File
    var onDone: () -> Void

    @State private var referenceFiles: [File] = []

    var body: some View {
        ImageGrid(referenceFiles) { file in
            NavigationLink(value: file) {
                FileGridCell(file: file)
            }
            .fileContextMenu(file: file)
        }
        .navigationTitle("References")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
        .task {
            referenceFiles = await file.referenceFiles()
        }
    }
}

#Preview {
    AsyncContentView {
        try await File.previewGND()
    } content: { file in
        FileReferencesView(file: file) {
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
