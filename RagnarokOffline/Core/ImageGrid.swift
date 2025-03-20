//
//  ImageGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/19.
//

import SwiftUI

struct ImageGrid<Content>: View where Content: View {
    var content: () -> Content

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [imageGridItem(sizeClass)], spacing: vSpacing(sizeClass), content: content)
                .padding(.horizontal, hSpacing(sizeClass))
                .padding(.vertical, vSpacing(sizeClass))
        }
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    init<Data, CellContent>(_ data: Data, @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent) where Content == ForEach<Data, Data.Element.ID, CellContent>, Data: RandomAccessCollection, Data.Element: Identifiable, CellContent: View {
        content = {
            ForEach(data, content: cellContent)
        }
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
