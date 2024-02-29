//
//  FileContextMenu.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/29.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FileContextMenu: View {
    typealias Action = () -> Void

    let file: File
    let previewAction: Action?
    let inspectRawDataAction: Action?
    let copyAction: Action?
    let deleteAction: Action?

    var body: some View {
        Group {
            Section {
                if file.canPreview {
                    Button {
                        previewAction?()
                    } label: {
                        HStack {
                            Text("Preview")
                            Spacer()
                            Image(systemName: "eye")
                        }
                    }
                }

                if file.rawDataRepresentable {
                    Button {
                        inspectRawDataAction?()
                    } label: {
                        HStack {
                            Text("Inspect Raw Data")
                            Spacer()
                            Image(systemName: "list.bullet.indent")
                        }
                    }
                }
            }

            Section {
                if file.canCopy {
                    Button {
                        copyAction?()
                    } label: {
                        HStack {
                            Text("Copy")
                            Spacer()
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }

                if file.canShare {
                    ShareLink("Share", item: file, preview: SharePreview(file.name))
                }
            }

            Section {
                if file.canDelete {
                    Button(role: .destructive) {
                        deleteAction?()
                    } label: {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
    }

    init(file: File, previewAction: Action? = nil, inspectRawDataAction: Action? = nil, copyAction: Action? = nil, deleteAction: Action? = nil) {
        self.file = file
        self.previewAction = previewAction
        self.inspectRawDataAction = inspectRawDataAction
        self.copyAction = copyAction
        self.deleteAction = deleteAction
    }
}
