//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FilesView: View {

    @EnvironmentObject var filePasteboard: FilePasteboard

    let title: String
    let file: File

    @State private var isLoaded = false
    @State private var isPreviewPresented = false
    @State private var files: [File] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 32) {
                ForEach(files) { file in
                    if file.isDirectory || file.isArchive {
                        NavigationLink {
                            FilesView(title: file.name, file: file)
                        } label: {
                            VStack {
                                FileThumbnailView(file: file)

                                Text(file.name)
                                    .lineLimit(2, reservesSpace: true)
                                    .font(.subheadline)
                                    .foregroundColor(.init(uiColor: .label))
                            }
                        }
                    } else {
                        Button {
                            isPreviewPresented.toggle()
                        } label: {
                            VStack {
                                FileThumbnailView(file: file)

                                Text(file.name)
                                    .lineLimit(2, reservesSpace: true)
                                    .font(.subheadline)
                                    .foregroundColor(.init(uiColor: .label))
                            }
                            .fullScreenCover(isPresented: $isPreviewPresented) {
                                FilePreviewPageView(file: file, files: files)
                            }
                        }
                        .contextMenu {
                            if !file.isDirectory && !file.isArchive {
                                Button {
                                    filePasteboard.copy(file)
                                } label: {
                                    HStack {
                                        Text("Copy")
                                        Spacer()
                                        Image(systemName: "doc.on.doc")
                                    }
                                }
                            }
                            if case .url(let url) = file, !file.isDirectory {
                                Button(role: .destructive) {
                                    do {
                                        try FileManager.default.removeItem(at: url)
                                        files.removeAll(where: { $0 == file })
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
            }
            .padding(32)
        }
        .overlay {
            if !isLoaded {
                ProgressView()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button {
                    if let file = file.pasteFromPasteboard(filePasteboard) {
                        var files = self.files
                        files.append(file)
                        files.sort()
                        self.files = files
                    }
                } label: {
                    HStack {
                        Text("Paste")
                        Spacer()
                        Image(systemName: "doc.on.clipboard")
                    }
                }
                .disabled(!file.isDirectory || !filePasteboard.hasFile)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .task {
            if !isLoaded {
                files = file.files().sorted()
                isLoaded = true
            }
        }
    }
}
