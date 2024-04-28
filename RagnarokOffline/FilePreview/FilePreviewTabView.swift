//
//  FilePreviewTabView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import ROFileSystem

struct FilePreviewTabView: View {
    let files: [File]
    @State var currentFile: File

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TabView(selection: $currentFile) {
                ForEach(files) { file in
                    FilePreviewView(file: file)
                        .tag(file)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle(currentFile.name)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: currentFile, preview: SharePreview(currentFile.name))
                }
            }
        }
    }
}
