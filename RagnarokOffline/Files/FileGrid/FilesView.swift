//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI

struct FilesView: View {
    var title: String
    var directory: File

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var searchText = ""
    @State private var files: [File] = []
    @State private var filteredFiles: [File] = []

    @State private var isHelpPresented = false
    @State private var fileToPreview: File?
    @State private var fileToShowRawData: File?
    @State private var fileToShowReferences: File?

    var body: some View {
        ImageGrid {
            ForEach(filteredFiles) { file in
                if file.hasFiles {
                    NavigationLink(value: file) {
                        FileGridCell(file: file)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        FileContextMenu(file: file, copyAction: {
                            FileSystem.shared.copy(file)
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
                        FileGridCell(file: file)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        FileContextMenu(file: file, previewAction: {
                            fileToPreview = file
                        }, showRawDataAction: {
                            fileToShowRawData = file
                        }, showReferencesAction: {
                            fileToShowReferences = file
                        }, copyAction: {
                            FileSystem.shared.copy(file)
                        }, deleteAction: {
                            deleteFile(file)
                        })
                    }
                }
            }
        }
        .background(.background)
        .overlay {
            if loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if loadStatus == .loaded && filteredFiles.isEmpty {
                ContentUnavailableView("No Files", systemImage: "folder.fill")
            }
        }
        .navigationDestination(for: File.self) { file in
            FilesView(title: file.name, directory: file)
        }
        .navigationTitle(title)
        .toolbar {
            Button {
                isHelpPresented.toggle()
            } label: {
                Image(systemName: "questionmark.circle")
            }

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
        .sheet(isPresented: $isHelpPresented) {
            NavigationStack {
                FileHelpView()
            }
        }
        .sheet(item: $fileToPreview) { file in
            NavigationStack {
                FilePreviewTabView(files: filteredFiles.filter({ $0.canPreview }), currentFile: file)
            }
        }
        .sheet(item: $fileToShowRawData) { file in
            NavigationStack {
                FileJSONViewer(file: file)
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

        files = await directory.files()
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
        if let file = FileSystem.shared.paste(to: directory), loadStatus == .loaded {
            files.append(file)
            files.sort()
            filterFiles()
        }
    }

    private func deleteFile(_ file: File) {
        if FileSystem.shared.remove(file) {
            files.removeAll(where: { $0 == file })
            filterFiles()
        }
    }
}

#Preview {
    FilesView(title: "", directory: .previewDataDirectory)
}
