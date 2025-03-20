//
//  FileReferencesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/6.
//

import SwiftUI

struct FileReferencesView: View {
    var file: File

    @Environment(\.dismiss) private var dismiss

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
        }
        .navigationTitle("References")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(item: $fileToPreview) { file in
            NavigationStack {
                FilePreviewTabView(files: referenceFiles.filter({ $0.canPreview }), currentFile: file)
            }
        }
        .task {
            referenceFiles = await file.referenceFiles()
        }
    }
}

#Preview {
    FileReferencesView(file: .previewGND)
}
