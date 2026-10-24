//
//  ItemComboView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/24.
//

import SwiftUI

struct ItemComboView: View {
    var itemCombo: ItemModel.ItemCombo

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(itemCombo.items) { item in
                    NavigationLink(value: item) {
                        ItemCell(item: item)
                    }
                }
            }

            if let script = itemCombo.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSubsectionView(text: script, monospaced: true) {
                    Text("Script", tableName: "Database")
                }
            }
        }
    }
}
