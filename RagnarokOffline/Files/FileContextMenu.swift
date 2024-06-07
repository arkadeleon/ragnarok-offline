//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//

import SwiftUI

struct FileContextMenu: View {
    var file: ObservableFile
    var previewAction: Action?
    var showRawDataAction: Action?
    var showReferencesAction: Action?
    var copyAction: Action?
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

                if file.rawDataRepresentable {
                    Button {
                        showRawDataAction?()
                    } label: {
                        Label("Raw Data", systemImage: "list.bullet.indent")
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
                if file.canCopy {
                    Button {
                        copyAction?()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }

                if file.canShare {
                    ShareLink("Share", item: file, preview: SharePreview(file.file.name))
                }
            }

            Section {
                if file.canDelete {
                    Button(role: .destructive) {
                        deleteAction?()
                    } label: {
                        Label("Delete", image: "trash")
                    }
                }
            }
        }
    }

    init(file: ObservableFile, previewAction: Action? = nil, showRawDataAction: Action? = nil, showReferencesAction: Action? = nil, copyAction: Action? = nil, deleteAction: Action? = nil) {
        self.file = file
        self.previewAction = previewAction
        self.showRawDataAction = showRawDataAction
        self.showReferencesAction = showReferencesAction
        self.copyAction = copyAction
        self.deleteAction = deleteAction
    }
}
