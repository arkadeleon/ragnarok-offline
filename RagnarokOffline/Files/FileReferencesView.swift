//
//  FileReferencesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/6.
//

import SwiftUI

struct FileReferencesView: View {
    var file: ObservableFile

    @Environment(\.dismiss) private var dismiss

    @State private var referenceFiles: [ObservableFile] = []
    @State private var fileToPreview: ObservableFile?

    var body: some View {
        ImageGrid {
            ForEach(referenceFiles) { file in
                Button {
                    if file.canPreview {
                        fileToPreview = file
                    }
                } label: {
                    FileGridCell(file: file)
                }
                .buttonStyle(.plain)
            }
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
            do {
                referenceFiles = try file.referenceFiles()
            } catch {
            }
        }
    }
}

#Preview {
    FileReferencesView(file: .previewGND)
}
