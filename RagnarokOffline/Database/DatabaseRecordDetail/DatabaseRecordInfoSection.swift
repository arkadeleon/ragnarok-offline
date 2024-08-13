//
//  DatabaseRecordInfoSection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/6.
//

import SwiftUI

struct DatabaseRecordInfoSection<Content, Header>: View where Content: View, Header: View {
    var verticalSpacing: CGFloat?
    @ViewBuilder var content: () -> Content
    @ViewBuilder var header: () -> Header

    var body: some View {
        VStack(spacing: 0) {
            header()
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 5)

            Divider()

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, verticalSpacing ?? 10)

            Divider()
        }
        .padding(.horizontal, 20)
    }

    init(_ titleKey: LocalizedStringKey, verticalSpacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) where Header == Text {
        self.verticalSpacing = verticalSpacing
        self.content = content
        self.header = {
            Text(titleKey)
        }
    }

    init(verticalSpacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.verticalSpacing = verticalSpacing
        self.content = content
        self.header = header
    }
}
