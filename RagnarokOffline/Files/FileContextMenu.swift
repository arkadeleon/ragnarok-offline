//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//

import SwiftUI

struct FileContextMenu: View {
    typealias Action = () -> Void

    var file: ObservableFile
    var previewAction: Action?
    var inspectRawDataAction: Action?
    var copyAction: Action?
    var deleteAction: Action?

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

                if file.file.rawDataRepresentable {
                    Button {
                        inspectRawDataAction?()
                    } label: {
                        Label("Inspect Raw Data", systemImage: "list.bullet.indent")
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

    init(file: ObservableFile, previewAction: Action? = nil, inspectRawDataAction: Action? = nil, copyAction: Action? = nil, deleteAction: Action? = nil) {
        self.file = file
        self.previewAction = previewAction
        self.inspectRawDataAction = inspectRawDataAction
        self.copyAction = copyAction
        self.deleteAction = deleteAction
    }
}
