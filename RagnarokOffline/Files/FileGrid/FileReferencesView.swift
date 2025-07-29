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
    @State private var fileToPreview: File?

    var body: some View {
        ImageGrid(referenceFiles) { file in
            Button {
                if file.canPreview {
                    fileToPreview = file
                }
            } label: {
                FileGridCell(file: file)
            }
            .buttonStyle(.plain)
            .fileContextMenu(file: file)
        }
        .navigationTitle("References")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
        .sheet(item: $fileToPreview) { file in
            NavigationStack {
                FilePreviewTabView(files: referenceFiles.filter({ $0.canPreview }), currentFile: file) {
                    fileToPreview = nil
                }
            }
            .presentationSizing(.page)
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
    .frame(width: 400, height: 300)
}
