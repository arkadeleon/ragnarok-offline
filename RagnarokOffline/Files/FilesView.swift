//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import ROFileSystem

struct FilesView: View {
    var title: String
    var directory: ObservableFile

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var searchText = ""
    @State private var files: [ObservableFile] = []
    @State private var filteredFiles: [ObservableFile] = []

    @State private var previewingFile: ObservableFile?
    @State private var inspectingRawDataFile: ObservableFile?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
                ForEach(filteredFiles) { file in
                    if file.file.isDirectory || file.file.isArchive {
                        NavigationLink(value: file) {
                            FileCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, copyAction: {
                                directory.file.copy(file.file)
                            }, deleteAction: {
                                deleteFile(file)
                            })
                        }
                    } else {
                        Button {
                            if file.file.canPreview {
                                previewingFile = file
                            }
                        } label: {
                            FileCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, previewAction: {
                                previewingFile = file
                            }, inspectRawDataAction: {
                                inspectingRawDataFile = file
                            }, copyAction: {
                                directory.file.copy(file.file)
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
        .navigationDestination(for: ObservableFile.self) { file in
            FilesView(title: file.file.name, directory: file)
        }
        .navigationTitle(title)
        .toolbar {
            Menu {
                Button {
                    pasteFile()
                } label: {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                .disabled(!directory.file.canPaste)
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
                FilePreviewTabView(files: filteredFiles.filter({ $0.file.canPreview }), currentFile: file)
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

        files = directory.file.files().sorted().map(ObservableFile.init)
        filterFiles()

        loadStatus = .loaded
    }

    private func filterFiles() {
        if searchText.isEmpty {
            filteredFiles = files
        } else {
            filteredFiles = files.filter { file in
                file.file.name.localizedStandardContains(searchText)
            }
        }
    }

    private func pasteFile() {
        if let file = directory.file.pasteFromPasteboard(FilePasteboard.shared), loadStatus == .loaded {
            files.append(ObservableFile(file: file))
            files.sort()
            filterFiles()
        }
    }

    private func deleteFile(_ file: ObservableFile) {
        if directory.file.delete(file.file) {
            files.removeAll(where: { $0 == file })
            filterFiles()
        }
    }
}
