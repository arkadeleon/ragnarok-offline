//
//  DatabaseRecordAttributesSectionView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/5.
//

import SwiftUI

struct DatabaseRecordAttributesSectionView: View {
    var titleKey: LocalizedStringKey
    var attributes: [DatabaseRecordAttribute]

    var body: some View {
        DatabaseRecordSectionView(titleKey, spacing: 10) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                ForEach(attributes) { attribute in
                    LabeledContent {
                        Text(attribute.value)
                    } label: {
                        Text(attribute.name)
                    }
                }
            }
        }
    }

    init(_ titleKey: LocalizedStringKey, attributes: [DatabaseRecordAttribute]) {
        self.titleKey = titleKey
        self.attributes = attributes
    }
}

#Preview {
    DatabaseRecordAttributesSectionView("Info", attributes: [
        DatabaseRecordAttribute(name: "ID", value: "#1002"),
        DatabaseRecordAttribute(name: "Name", value: "Poring"),
        DatabaseRecordAttribute(name: "Level", value: 1),
        DatabaseRecordAttribute(name: "HP", value: 55),
    ])
}
