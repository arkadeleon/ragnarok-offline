//
//  DatabaseRecordDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/19.
//

import SwiftUI

struct DatabaseRecordDetailView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            LazyVStack {
                Group(subviews: content()) { subviews in
                    ForEach(subviews.dropLast()) { subview in
                        subview
                            .padding(.bottom)
                        Divider()
                    }
                    if let lastSubview = subviews.last {
                        lastSubview
                    }
                }
            }
            .padding(.horizontal, hSpacing(sizeClass))
        }
        .background(.background)
    }
}

#Preview {
    DatabaseRecordDetailView {
        DatabaseRecordSectionView("Info", attributes: [
            DatabaseRecordAttribute(name: "ID", value: "#1002"),
            DatabaseRecordAttribute(name: "Name", value: "Poring"),
            DatabaseRecordAttribute(name: "Level", value: 1),
            DatabaseRecordAttribute(name: "HP", value: 55),
        ])

        DatabaseRecordSectionView("Description", text: "Poring")
    }
}
