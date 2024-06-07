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

    @State private var fileToPreview: ObservableFile?
    @State private var fileToShowRawData: ObservableFile?
    @State private var fileToShowReferences: ObservableFile?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30) {
                ForEach(filteredFiles) { file in
                    if file.file.info.type == .directory || file.file.info.type == .grf {
                        NavigationLink(value: file) {
                            FileCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, copyAction: {
                                FileSystem.shared.copy(file.file)
                            }, deleteAction: {
                                deleteFile(file)
                            })
                        }
                    } else {
                        Button {
                            if file.canPreview {
                                fileToPreview = file
                            }
                        } label: {
                            FileCell(file: file)
                        }
                        .contextMenu {
                            FileContextMenu(file: file, previewAction: {
                                fileToPreview = file
                            }, showRawDataAction: {
                                fileToShowRawData = file
                            }, showReferencesAction: {
                                fileToShowReferences = file
                            }, copyAction: {
                                FileSystem.shared.copy(file.file)
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
        .sheet(item: $fileToPreview) { file in
            NavigationStack {
                FilePreviewTabView(files: filteredFiles.filter({ $0.canPreview }), currentFile: file)
            }
        }
        .sheet(item: $fileToShowRawData) { file in
            NavigationStack {
                FileRawDataView(file: file)
            }
        }
        .sheet(item: $fileToShowReferences) { file in
            NavigationStack {
                FileReferencesView(file: file)
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

        files = directory.file.files().map(ObservableFile.init).sorted()
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
        if let file = FileSystem.shared.paste(to: directory.file), loadStatus == .loaded {
            files.append(ObservableFile(file: file))
            files.sort()
            filterFiles()
        }
    }

    private func deleteFile(_ file: ObservableFile) {
        if FileSystem.shared.remove(file.file) {
            files.removeAll(where: { $0 == file })
            filterFiles()
        }
    }
}
