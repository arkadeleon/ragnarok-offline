//
//  ImageGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/19.
//

import SwiftUI

struct ImageGrid<Content>: View where Content: View {
    var itemWidth: CGFloat
    var content: Content

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth), spacing: hSpacing(sizeClass))], spacing: vSpacing(sizeClass)) {
                content
            }
            .padding(.horizontal, hSpacing(sizeClass))
            .padding(.vertical, vSpacing(sizeClass))
        }
        .buttonStyle(.borderless)
    }

    init(itemWidth: CGFloat = 100, @ViewBuilder content: () -> Content) {
        self.itemWidth = itemWidth
        self.content = content()
    }

    init<Data, CellContent>(
        _ data: Data,
        itemWidth: CGFloat = 100,
        @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent
    ) where Content == ForEach<Data, Data.Element.ID, CellContent>, Data: RandomAccessCollection, Data.Element: Identifiable, CellContent: View {
        self.itemWidth = itemWidth
        self.content = ForEach(data, content: cellContent)
    }
}

#Preview {
    ImageGrid {
        Image(systemName: "folder")
        Image(systemName: "folder")
        Image(systemName: "folder")
        Image(systemName: "folder")
        Image(systemName: "folder")
        Image(systemName: "folder")
    }
    .font(.system(size: 30))
}
