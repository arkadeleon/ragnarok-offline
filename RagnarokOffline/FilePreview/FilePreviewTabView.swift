//
//  FilePreviewTabView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import ROFileSystem

struct FilePreviewTabView: View {
    var files: [ObservableFile]
    @State var currentFile: ObservableFile

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(macOS)
        FilePreviewView(file: currentFile)
            .frame(height: 400)
            .navigationTitle(currentFile.file.name)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    ShareLink(item: currentFile, preview: SharePreview(currentFile.file.name))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        #else
        TabView(selection: $currentFile) {
            ForEach(files) { file in
                FilePreviewView(file: file)
                    .tag(file)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationTitle(currentFile.file.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: currentFile, preview: SharePreview(currentFile.file.name))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        #endif
    }
}
