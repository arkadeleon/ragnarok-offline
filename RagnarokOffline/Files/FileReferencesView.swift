//
//  FileReferencesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/6.
//

import SwiftUI

struct FileReferencesView: View {
    var file: ObservableFile

    @State private var referenceFiles: [ObservableFile] = []
    @State private var fileToPreview: ObservableFile?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
                ForEach(referenceFiles) { file in
                    Button {
                        if file.canPreview {
                            fileToPreview = file
                        }
                    } label: {
                        FileCell(file: file)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .navigationTitle("References")
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
    FileReferencesView(file: PreviewFiles.gndFile)
}
