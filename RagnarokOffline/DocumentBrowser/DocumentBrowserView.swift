//
//  DocumentBrowserView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DocumentBrowserView: View {

    @EnvironmentObject var documentPasteboard: DocumentPasteboard

    let title: String
    let document: DocumentWrapper

    @State private var isLoaded = false
    @State private var documents: [DocumentWrapper] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 32) {
                ForEach(documents) { document in
                    NavigationLink {
                        if document.isDirectory || document.isArchive {
                            DocumentBrowserView(title: document.name, document: document)
                        } else {
                            DocumentDetailView(document: document)
                        }
                    } label: {
                        VStack {
                            DocumentThumbnailView(document: document)

                            Text(document.name)
                                .lineLimit(2, reservesSpace: true)
                                .font(.subheadline)
                                .foregroundColor(.init(uiColor: .label))
                        }
                    }
                    .contextMenu {
                        if !document.isDirectory && !document.isArchive {
                            Button {
                                documentPasteboard.copy(document)
                            } label: {
                                HStack {
                                    Text("Copy")
                                    Spacer()
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                        if case .url(let url) = document, !document.isDirectory {
                            Button(role: .destructive) {
                                do {
                                    try FileManager.default.removeItem(at: url)
                                    documents.removeAll(where: { $0 == document })
                                } catch {

                                }
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
            .padding(32)
        }
        .toolbar {
            Menu {
                Button {
                    if let document = document.pasteFromPasteboard(documentPasteboard) {
                        var documents = self.documents
                        documents.append(document)
                        documents.sort()
                        self.documents = documents
                    }
                } label: {
                    HStack {
                        Text("Paste")
                        Spacer()
                        Image(systemName: "doc.on.clipboard")
                    }
                }
                .disabled(!document.isDirectory || !documentPasteboard.hasDocument)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .overlay {
            if !isLoaded {
                ProgressView()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !isLoaded {
                documents = document.documentWrappers().sorted()
                isLoaded = true
            }
        }
    }
}
