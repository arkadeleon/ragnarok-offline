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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], spacing: 30, content: content)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
            } regular: {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 40)], spacing: 60, content: content)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 60)
            }
        }
    }
}

#Preview {
    ImageGrid {
        Text("")
    }
}
