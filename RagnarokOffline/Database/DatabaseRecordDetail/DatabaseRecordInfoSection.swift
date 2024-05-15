//
//  DatabaseRecordInfoSection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/6.
//

import SwiftUI

struct DatabaseRecordInfoSection<Header, Content>: View where Header: View, Content: View {
    let verticalSpacing: CGFloat
    let header: () -> Header
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            header()
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 5)

            Divider()

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, verticalSpacing)

            Divider()
        }
        .padding(.horizontal, 20)
    }

    init(_ title: String, verticalSpacing: CGFloat = 10, @ViewBuilder content: @escaping () -> Content) where Header == Text {
        self.verticalSpacing = verticalSpacing
        self.header = { Text(title) }
        self.content = content
    }

    init(verticalSpacing: CGFloat = 10, @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.verticalSpacing = verticalSpacing
        self.header = header
        self.content = content
    }
}
