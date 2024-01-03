//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct ItemDetailView: View {
    let item: RAItem

    @State private var itemPreview: UIImage?
    @State private var itemDescription: String?

    var body: some View {
        List {
            VStack(alignment: .center) {
                if let itemPreview {
                    Image(uiImage: itemPreview)
                } else {
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150, alignment: .center)

            Section("Info") {
                DatabaseRecordField(name: "ID", value: "#\(item.itemID)")
                DatabaseRecordField(name: "Aegis Name", value: item.aegisName)
                DatabaseRecordField(name: "Name", value: item.name)
                DatabaseRecordField(name: "Type", value: NSStringFromRAItemType(item.type))
                DatabaseRecordField(name: "Buy", value: "\(item.buy)z")
                DatabaseRecordField(name: "Sell", value: "\(item.sell)z")
            }

            if let itemDescription {
                Section("Description") {
                    Text(itemDescription)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            itemPreview = await ClientResourceManager.shared.itemPreviewImage(item.itemID)
            itemDescription = ClientScriptManager.shared.itemDescription(item.itemID)
        }
    }
}

#Preview {
    ItemDetailView(item: RAItem())
}
