//
//  FilePreviewTabView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI

struct FilePreviewTabView: View {
    var files: [File]
    @State var currentFile: File
    var onDone: () -> Void

    var body: some View {
        #if os(macOS)
        FilePreviewView(file: currentFile)
            .frame(height: 400)
            .navigationTitle(currentFile.name)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    ShareLink(item: currentFile, preview: SharePreview(currentFile.name))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDone)
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
        .navigationTitle(currentFile.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: currentFile, preview: SharePreview(currentFile.name))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onDone) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        #endif
    }

    init(files: [File], currentFile: File, onDone: @escaping () -> Void) {
        self.files = files
        self.currentFile = currentFile
        self.onDone = onDone
    }
}
