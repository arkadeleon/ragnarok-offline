//
//  ItemNameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import RODatabase
import ROResources
import SwiftUI

struct ItemNameView: View {
    var item: Item

    @State private var localizedItemName: String?

    private var itemDisplayName: String {
        let name = localizedItemName ?? item.name
        return item.slots > 0 ? name + " [\(item.slots)]" : name
    }

    var body: some View {
        Text(itemDisplayName)
            .task {
                localizedItemName = await ItemLocalization.shared.localizedName(for: item.id)
            }
    }
}

//#Preview {
//    ItemNameView()
//}
