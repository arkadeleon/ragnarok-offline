//
//  DatabaseRecordInfoSection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/6.
//

import SwiftUI

struct DatabaseRecordSectionView<Content, Header>: View where Content: View, Header: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var header: () -> Header

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView(content: header)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)

            content()
        }
    }

    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.content = content
        self.header = header
    }

    init(_ titleKey: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) where Header == Text {
        self.content = content
        self.header = {
            Text(titleKey)
        }
    }

    init(_ titleKey: LocalizedStringKey, text: String, monospaced: Bool = false) where Content == DatabaseRecordSectionTextContent, Header == Text {
        self.content = {
            DatabaseRecordSectionTextContent(text: text, monospaced: monospaced)
        }
        self.header = {
            Text(titleKey)
        }
    }

    init(_ titleKey: LocalizedStringKey, text: AttributedString) where Content == DatabaseRecordSectionTextContent, Header == Text {
        self.content = {
            DatabaseRecordSectionTextContent(text: text)
        }
        self.header = {
            Text(titleKey)
        }
    }

    init(_ titleKey: LocalizedStringKey, attributes: [DatabaseRecordAttribute]) where Content == DatabaseRecordSectionAttributesContent, Header == Text {
        self.content = {
            DatabaseRecordSectionAttributesContent(attributes: attributes)
        }
        self.header = {
            Text(titleKey)
        }
    }
}

struct DatabaseRecordSectionTextContent: View {
    var text: Text

    var body: some View {
        text.frame(maxWidth: .infinity, alignment: .leading)
    }

    init(text: String, monospaced: Bool) {
        self.text = Text(text)
            .monospaced(monospaced)
    }

    init(text: AttributedString) {
        self.text = Text(text)
    }
}

struct DatabaseRecordSectionAttributesContent: View {
    var attributes: [DatabaseRecordAttribute]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
            ForEach(attributes) { attribute in
                VStack {
                    HStack {
                        Text(attribute.name)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(attribute.value)
                    }
                }
            }
        }
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
    .padding()
}

#Preview {
    DatabaseRecordSectionView("Info", attributes: [
        DatabaseRecordAttribute(name: "ID", value: "#1002"),
        DatabaseRecordAttribute(name: "Name", value: "Poring"),
        DatabaseRecordAttribute(name: "Level", value: 1),
        DatabaseRecordAttribute(name: "HP", value: 55),
    ])
    .padding()
}
