//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//

import SwiftUI

struct FileContextMenu: View {
    var file: File
    var previewAction: Action?
    var showRawDataAction: Action?
    var showReferencesAction: Action?
    var deleteAction: Action?

    typealias Action = () -> Void

    var body: some View {
        Group {
            Section {
                if file.canPreview {
                    Button {
                        previewAction?()
                    } label: {
                        Label("Preview", systemImage: "eye")
                    }
                }

                if file.jsonRepresentable {
                    Button {
                        showRawDataAction?()
                    } label: {
                        Label("JSON Viewer", systemImage: "list.bullet.indent")
                    }
                }

                if file.hasReferences {
                    Button {
                        showReferencesAction?()
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
                if FileSystem.shared.canDeleteFile(file) {
                    Button(role: .destructive) {
                        deleteAction?()
                    } label: {
                        Label("Delete", image: "trash")
                    }
                }
            }
        }
    }

    init(file: File, previewAction: Action? = nil, showRawDataAction: Action? = nil, showReferencesAction: Action? = nil, deleteAction: Action? = nil) {
        self.file = file
        self.previewAction = previewAction
        self.showRawDataAction = showRawDataAction
        self.showReferencesAction = showReferencesAction
        self.deleteAction = deleteAction
    }
}

#Preview {
    Text(File.previewRSW.name)
        .contextMenu {
            FileContextMenu(file: .previewRSW)
        }
}
