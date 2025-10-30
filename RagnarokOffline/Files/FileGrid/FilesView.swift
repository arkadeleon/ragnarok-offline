//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI

struct FilesView: View {
    var titleKey: LocalizedStringKey?
    var directory: File

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var searchText = ""
    @State private var files: [File] = []
    @State private var filteredFiles: [File] = []

    @State private var isFileImporterPresented = false

    var body: some View {
        ImageGrid(filteredFiles) { file in
            if file.hasFiles {
                NavigationLink(value: file) {
                    FileGridCell(file: file)
                }
                .fileContextMenu(file: file, onDelete: onDeleteFile)
            } else {
                NavigationLink(value: file) {
                    FileGridCell(file: file)
                }
                .fileContextMenu(file: file, onDelete: onDeleteFile)
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
        .toolbar(content: toolbarContent)
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            filterFiles()
        }
        .onChange(of: searchText) {
            filterFiles()
        }
        .refreshable {
            await reload()
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.data],
            onCompletion: onFileImporterCompletion
        )
        .task {
            await load()
        }
    }

    private var title: Text {
        if let titleKey {
            Text(titleKey)
        } else {
            Text(directory.name)
        }
    }

    init(_ titleKey: LocalizedStringKey? = nil, directory: File) {
        self.titleKey = titleKey
        self.directory = directory
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        if directory.location == .client, directory.utType == .folder {
            ToolbarItem {
                Button {
                    isFileImporterPresented = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }

        #if os(macOS)
        if directory.utType == .folder {
            if #available(macOS 26.0, *) {
                ToolbarSpacer()
            }

            ToolbarItem {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([directory.url])
                } label: {
                    Image(systemName: "folder")
                }
            }
        }
        #endif
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

    private func reload() async {
        files = await directory.files()
        filterFiles()
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

    private func onDeleteFile(_ file: File) {
        files.removeAll(where: { $0 == file })
        filterFiles()
    }

    private func onFileImporterCompletion(_ result: Result<URL, any Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            if accessed {
                let dstURL = directory.url.appending(component: url.lastPathComponent)
                do {
                    try FileManager.default.copyItem(at: url, to: dstURL)
                } catch {
                    logger.warning("\(error)")
                }
                Task {
                    await reload()
                }
            }
            url.stopAccessingSecurityScopedResource()
        case .failure(let error):
            logger.warning("\(error)")
        }
    }
}

#Preview {
    FilesView(directory: .previewGRF())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
