//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import ROFileSystem

struct FilesView: View {
    let title: String
    let directory: File

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var searchText = ""
    @State private var files: [File] = []
    @State private var filteredFiles: [File] = []

    @State private var previewingFile: File?
    @State private var inspectingRawDataFile: File?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
                ForEach(filteredFiles) { file in
                    if file.isDirectory || file.isArchive {
                        NavigationLink(value: file) {
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
            if loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if loadStatus == .loaded && filteredFiles.isEmpty {
                EmptyContentView("Empty Folder")
            }
        }
        .navigationDestination(for: File.self) { file in
            FilesView(title: file.name, directory: file)
                #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
        .navigationTitle(title)
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
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            filterFiles()
        }
        .onChange(of: searchText) {
            filterFiles()
        }
        .sheet(item: $previewingFile) { file in
            NavigationStack {
                FilePreviewTabView(files: filteredFiles.filter({ $0.canPreview }), currentFile: file)
            }
        }
        .sheet(item: $inspectingRawDataFile) { file in
            NavigationStack {
                FileRawDataView(file: file)
            }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        files = directory.files().sorted()
        filterFiles()

        loadStatus = .loaded
    }

    private func filterFiles() {
        if searchText.isEmpty {
            filteredFiles = files
        } else {
            filteredFiles = files.filter { file in
                file.name.localizedStandardContains(searchText)
            }
        }
    }

    private func pasteFile() {
        if let file = directory.pasteFromPasteboard(FilePasteboard.shared), loadStatus == .loaded {
            files.append(file)
            files.sort()
            filterFiles()
        }
    }

    private func deleteFile(_ file: File) {
        if directory.delete(file) {
            files.removeAll(where: { $0 == file })
            filterFiles()
        }
    }
}
