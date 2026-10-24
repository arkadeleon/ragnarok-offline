//
//  DatabaseRecordSubsectionView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/24.
//

import SwiftUI

struct DatabaseRecordSubsectionView<Content, Header>: View where Content: View, Header: View {
    var content: Content
    var header: Header

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
                .font(.headline)
                .foregroundStyle(Color.secondary)

            content
        }
    }

    init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
        self.content = content()
        self.header = header()
    }

    init(text: String, monospaced: Bool = false, @ViewBuilder header: () -> Header) where Content == DatabaseRecordSectionTextContent {
        self.content = DatabaseRecordSectionTextContent(text: text, monospaced: monospaced)
        self.header = header()
    }

    init(attributes: [DatabaseRecordAttribute], @ViewBuilder header: () -> Header) where Content == DatabaseRecordSectionAttributesContent {
        self.content = DatabaseRecordSectionAttributesContent(attributes: attributes)
        self.header = header()
    }
}
