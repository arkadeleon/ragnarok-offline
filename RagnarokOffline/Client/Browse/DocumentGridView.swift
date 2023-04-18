//
//  DocumentGridView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DocumentGridView: View {

    let title: String
    let document: DocumentWrapper

    @State private var isLoading = true
    @State private var documents: [DocumentWrapper] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(documents, id: \.name) { document in
                    NavigationLink {
                        if document.isDirectory || document.isArchive {
                            DocumentGridView(title: document.name, document: document)
                        } else {
                            DocumentDetailView(document: document)
                        }
                    } label: {
                        VStack {
                            Image(uiImage: document.icon ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            Text(document.name)
                                .lineLimit(2, reservesSpace: true)
                                .font(.subheadline)
                                .foregroundColor(.init(uiColor: .label))
                        }
                    }
                }
            }
            .padding(32)
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if documents.isEmpty {
                isLoading = true
                documents = document.documentWrappers()
                isLoading = false
            }
        }
    }
}
