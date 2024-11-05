//
//  DatabaseRecordInfoSection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/6.
//

import SwiftUI

struct DatabaseRecordSectionView<Content, Header>: View where Content: View, Header: View {
    var spacing: CGFloat?
    @ViewBuilder var content: () -> Content
    @ViewBuilder var header: () -> Header

    var body: some View {
        Section {
            VStack(spacing: spacing) {
                Divider()

                content()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
            }
            .padding(.horizontal)
        } header: {
            header()
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.background.opacity(0.75))
        }
    }

    init(_ titleKey: LocalizedStringKey, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) where Header == Text {
        self.spacing = spacing
        self.content = content
        self.header = {
            Text(titleKey)
        }
    }

    init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.spacing = spacing
        self.content = content
        self.header = header
    }
}

#Preview {
    DatabaseRecordSectionView("Info") {
        Grid {
            GridRow {
                LabeledContent("ID", value: "#1002")
                LabeledContent("Name", value: "Poring")
            }
            GridRow {
                LabeledContent("Level", value: "1")
                LabeledContent("HP", value: "55")
            }
        }
    }
}
