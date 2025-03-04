//
//  ImageGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/19.
//

import SwiftUI

struct ImageGrid<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            ResponsiveView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 32, content: content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
            } regular: {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 32)], spacing: 64, content: content)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 64)
            }
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
