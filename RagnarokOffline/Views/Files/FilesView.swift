//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FilesView: View {
    let title: String
    let directory: File

    @State private var isLoaded = false
    @State private var searchText = ""
    @State private var files: [File] = []
    @State private var filteredFiles: [File] = []

    @State private var previewingFile: File?
    @State private var inspectingRawDataFile: File?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
                ForEach(filteredFiles) { file in
                    if file.isDirectory || file.isArchive {
                        NavigationLink {
                            FilesView(title: file.name, directory: file)
                        } label: {
                            FileGridCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, copyAction: {
                                directory.copy(file)
                            }, deleteAction: {
                                if directory.delete(file) {
                                    files.removeAll(where: { $0 == file })
                                }
                            })
                        }
                    } else {
                        Button {
                            if file.canPreview {
                                previewingFile = file
                            }
                        } label: {
                            FileGridCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, previewAction: {
                                previewingFile = file
                            }, inspectRawDataAction: {
                                inspectingRawDataFile = file
                            }, copyAction: {
                                directory.copy(file)
                            }, deleteAction: {
                                if directory.delete(file) {
                                    files.removeAll(where: { $0 == file })
                                }
                            })
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .overlay {
            if !isLoaded {
                ProgressView()
            }
        }
        .sheet(item: $previewingFile) { file in
            FilePreviewPageView(file: file, files: files.filter({ $0.canPreview }))
        }
        .sheet(item: $inspectingRawDataFile) { file in
            FileRawDataView(file: file)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button {
                    if let file = directory.pasteFromPasteboard(FilePasteboard.shared) {
                        var files = self.files
                        files.append(file)
                        files.sort()
                        self.files = files
                    }
                } label: {
                    HStack {
                        Text("Paste")
                        Spacer()
                        Image(systemName: "doc.on.clipboard")
                    }
                }
                .disabled(!directory.canPaste)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            filterFiles()
        }
        .onChange(of: searchText) { _ in
            filterFiles()
        }
        .task {
            if !isLoaded {
                files = directory.files().sorted()
                filteredFiles = files
                isLoaded = true
            }
        }
    }

    private func filterFiles() {
        guard isLoaded else {
            return
        }

        if searchText.isEmpty {
            filteredFiles = files
        } else {
            filteredFiles = files.filter { file in
                file.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
