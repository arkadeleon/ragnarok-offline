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

    @State private var status: AsyncContentStatus<[File]> = .notYetLoaded
    @State private var searchText = ""
    @State private var filteredFiles: [File] = []

    @State private var previewingFile: File?
    @State private var inspectingRawDataFile: File?

    var body: some View {
        AsyncContentView(status: status) { files in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
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
                                    deleteFile(file)
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
                                    deleteFile(file)
                                })
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
            .overlay {
                if filteredFiles.isEmpty {
                    EmptyContentView("Empty Folder")
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button {
                    pasteFile()
                } label: {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                .disabled(!directory.canPaste)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            filterFiles()
        }
        .onChange(of: searchText) { _ in
            filterFiles()
        }
        .sheet(item: $previewingFile) { file in
            FilePreviewPageView(file: file, files: filteredFiles.filter({ $0.canPreview }))
        }
        .sheet(item: $inspectingRawDataFile) { file in
            FileRawDataView(file: file)
        }
        .task {
            await load()
        }
    }

    private func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        let files = directory.files().sorted()
        status = .loaded(files)
        filterFiles()
    }

    private func filterFiles() {
        guard case .loaded(let files) = status else {
            return
        }

        if searchText.isEmpty {
            filteredFiles = files
        } else {
            filteredFiles = files.filter { file in
                file.name.localizedStandardContains(searchText)
            }
        }
    }

    private func pasteFile() {
        if let file = directory.pasteFromPasteboard(FilePasteboard.shared) {
            if case .loaded(var files) = status {
                files.append(file)
                files.sort()
                status = .loaded(files)
                filterFiles()
            }
        }
    }

    private func deleteFile(_ file: File) {
        if directory.delete(file) {
            if case .loaded(var files) = status {
                files.removeAll(where: { $0 == file })
                status = .loaded(files)
                filterFiles()
            }
        }
    }
}
