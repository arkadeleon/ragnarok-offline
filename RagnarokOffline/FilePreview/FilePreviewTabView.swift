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
        TabView(selection: $currentFile) {
            ForEach(files) { file in
                FilePreviewView(file: file)
                    .tag(file)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationTitle(currentFile.file.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: currentFile, preview: SharePreview(currentFile.file.name))
            }
        }
    }
}
