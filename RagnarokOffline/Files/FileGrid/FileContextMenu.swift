//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//

import SwiftUI

struct FileContextMenu: ViewModifier {
    var file: File
    var onPreview: ((File) -> Void)?
    var onDelete: ((File) -> Void)?

    @State private var isJSONViewerPresented = false
    @State private var isReferencesPresented = false

    init(file: File, onPreview: ((File) -> Void)? = nil, onDelete: ((File) -> Void)? = nil) {
        self.file = file
        self.onPreview = onPreview
        self.onDelete = onDelete
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Section {
                    if let onPreview, file.canPreview {
                        Button {
                            onPreview(file)
                        } label: {
                            Label("Preview", systemImage: "eye")
                        }
                    }

                    if file.jsonRepresentable {
                        Button {
                            isJSONViewerPresented.toggle()
                        } label: {
                            Label("JSON Viewer", systemImage: "list.bullet.indent")
                        }
                    }

                    if file.hasReferences {
                        Button {
                            isReferencesPresented.toggle()
                        } label: {
                            Label("References", systemImage: "link")
                        }
                    }
                }

                Section {
                    if FileSystem.shared.canExtractFile(file) {
                        Button {
                            do {
                                try FileSystem.shared.extractFile(file)
                            } catch {
                                logger.warning("\(error.localizedDescription)")
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
                    if let onDelete, FileSystem.shared.canDeleteFile(file) {
                        Button(role: .destructive) {
                            onDelete(file)
                        } label: {
                            Label("Delete", image: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $isJSONViewerPresented) {
                NavigationStack {
                    FileJSONViewer(file: file)
                }
            }
            .sheet(isPresented: $isReferencesPresented) {
                NavigationStack {
                    FileReferencesView(file: file)
                }
            }
    }
}

extension View {
    func fileContextMenu(file: File, onPreview: ((File) -> Void)? = nil, onDelete: ((File) -> Void)? = nil) -> some View {
        modifier(FileContextMenu(file: file, onPreview: onPreview, onDelete: onDelete))
    }
}

#Preview {
    Text(File.previewRSW.name)
        .fileContextMenu(file: .previewRSW)
}
