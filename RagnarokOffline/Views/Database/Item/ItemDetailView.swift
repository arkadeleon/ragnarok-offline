//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemDetailView: View {
    let database: Database
    let item: Item

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
                LabeledContent("ID", value: "#\(item.id)")
                LabeledContent("Aegis Name", value: item.aegisName)
                LabeledContent("Name", value: item.name)
                LabeledContent("Type", value: item.type.description)
                LabeledContent("Buy", value: "\(item.buy)z")
                LabeledContent("Sell", value: "\(item.sell)z")
            }

            if let itemDescription {
                Section("Description") {
                    Text(itemDescription)
                }
            }

            if let script = item.script {
                Section("Script") {
                    Text(script.trimmingCharacters(in: .whitespacesAndNewlines))
                        .monospaced()
                }
            }

            if let equipScript = item.equipScript {
                Section("Equip Script") {
                    Text(equipScript.trimmingCharacters(in: .whitespacesAndNewlines))
                        .monospaced()
                }
            }

            if let unEquipScript = item.unEquipScript {
                Section("Unequip Script") {
                    Text(unEquipScript.trimmingCharacters(in: .whitespacesAndNewlines))
                        .monospaced()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            itemPreview = await ClientResourceManager.shared.itemPreviewImage(item.id)
            itemDescription = ClientScriptManager.shared.itemDescription(item.id)
        }
    }
}
