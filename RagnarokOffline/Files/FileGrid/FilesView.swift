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

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var searchText = ""
    @State private var files: [File] = []
    @State private var filteredFiles: [File] = []

    @State private var fileToPreview: File?

    var body: some View {
        ImageGrid(filteredFiles) { file in
            if file.hasFiles {
                NavigationLink(value: file) {
                    FileGridCell(file: file)
                }
                .buttonStyle(.plain)
                .fileContextMenu(file: file, onDelete: deleteFile)
            } else {
                Button {
                    if file.canPreview {
                        fileToPreview = file
                    }
                } label: {
                    FileGridCell(file: file)
                }
                .buttonStyle(.plain)
                .fileContextMenu(file: file, onDelete: deleteFile)
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
        .navigationTitle(title)
        .toolbar {
            #if os(macOS)
            if directory.utType == .folder {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([directory.url])
                } label: {
                    Image(systemName: "folder")
                }
            }
            #endif
        }
        .searchable(text: $searchText, placement: searchFieldPlacement(sizeClass))
        .onSubmit(of: .search) {
            filterFiles()
        }
        .onChange(of: searchText) {
            filterFiles()
        }
        .sheet(item: $fileToPreview) { file in
            NavigationStack {
                FilePreviewTabView(files: filteredFiles.filter({ $0.canPreview }), currentFile: file) {
                    fileToPreview = nil
                }
            }
            .presentationSizing(.page)
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

    private func deleteFile(_ file: File) {
        do {
            try FileSystem.shared.deleteFile(file)
            files.removeAll(where: { $0 == file })
            filterFiles()
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }
}

#Preview {
    FilesView(title: "", directory: .previewGRF())
        .frame(width: 400, height: 300)
}
