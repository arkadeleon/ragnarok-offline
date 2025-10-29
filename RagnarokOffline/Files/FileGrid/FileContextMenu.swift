//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//

import SwiftUI

struct FileContextMenu: ViewModifier {
    var file: File
    var onDelete: ((File) -> Void)?

    @Environment(\.fileSystem) private var fileSystem

    @State private var isJSONViewerPresented = false

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Section {
                    if file.jsonRepresentable {
                        Button {
                            isJSONViewerPresented.toggle()
                        } label: {
                            Label("JSON Viewer", systemImage: "list.bullet.indent")
                        }
                    }

                    if file.hasReferences {
                        NavigationLink(value: FileGroup(file: file, type: .references)) {
                            Label("References", systemImage: "link")
                        }
                    }
                }

                Section {
                    if fileSystem.canExtractFile(file) {
                        Button {
                            Task {
                                do {
                                    try await fileSystem.extractFile(file)
                                } catch {
                                    logger.warning("\(error)")
                                }
                            }
                        } label: {
                            Label("Extract", systemImage: "arrow.up.bin")
                        }
                    }

                    if file.canShare {
                        ShareLink("Share", item: file, preview: SharePreview(file.name))
                    }
                }

                Section {
                    if fileSystem.canDeleteFile(file) {
                        Button(role: .destructive) {
                            do {
                                try fileSystem.deleteFile(file)
                                onDelete?(file)
                            } catch {
                                logger.warning("\(error)")
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $isJSONViewerPresented) {
                NavigationStack {
                    FileJSONViewer(file: file) {
                        isJSONViewerPresented.toggle()
                    }
                }
            }
    }
}

extension View {
    func fileContextMenu(file: File, onDelete: ((File) -> Void)? = nil) -> some View {
        modifier(FileContextMenu(file: file, onDelete: onDelete))
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSW()
    } content: { file in
        Text(file.name)
            .fileContextMenu(file: file)
    }
    .frame(width: 100, height: 50)
}
