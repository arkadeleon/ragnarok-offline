//
//  DocumentItemsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DocumentItemsView: View {

    let title: String
    let documentItem: DocumentItem

    @State private var isLoading = true
    @State private var childDocumentItems: [DocumentItem] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(childDocumentItems) { documentItem in
                    NavigationLink {
                        switch documentItem {
                        case .directory, .grf, .entryGroup:
                            DocumentItemsView(title: documentItem.title, documentItem: documentItem)
                        case .previewItem(let previewItem):
                            PreviewItemView(previewItem: previewItem)
                        }
                    } label: {
                        VStack {
                            Image(uiImage: documentItem.icon ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            Text(documentItem.title)
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
            isLoading = true
            childDocumentItems = documentItem.children?.sorted() ?? []
            isLoading = false
        }
    }
}
