//
//  DatabaseRecordInfoSection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/6.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DatabaseRecordInfoSection<Header, Content>: View where Header: View, Content: View {
    let header: Header
    let content: Content

    var body: some View {
        VStack {
            header
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            content
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
        }
        .padding()
    }

    init(_ title: String, @ViewBuilder content: () -> Content) where Header == Text {
        self.header = Text(title)
        self.content = content()
    }

    init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
        self.header = header()
        self.content = content()
    }
}
