//
//  CharacterEquipmentListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/21.
//

import RagnarokResources
import SwiftUI

struct CharacterEquipmentListView: View {
    var category: CharacterEquipmentCategory
    @Binding var selection: ItemModel?

    @Environment(DatabaseModel.self) private var database
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var items: [ItemModel] = []
    @State private var filteredItems: [ItemModel] = []

    var body: some View {
        List {
            Button {
                selection = nil
                dismiss()
            } label: {
                HStack {
                    Text("None", tableName: "CharacterSimulator")
                        .foregroundStyle(Color.primary)

                    Spacer()

                    if selection == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.link)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            ForEach(filteredItems) { item in
                Button {
                    selection = item
                    dismiss()
                } label: {
                    HStack {
                        ItemCell(item: item)

                        if selection == item {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.link)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle(category.nameResource)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDoneButton {
                dismiss()
            }
        }
        .adaptiveSearch(text: $searchText)
        .overlay {
            if items.isEmpty {
                ProgressView()
            }
        }
        .task(id: "\(searchText)") {
            if items.isEmpty {
                await database.fetchItems()
                items = database.items.filter(category.includes(_:))
            }

            filteredItems = await matchingItems(searchText, in: items)
        }
    }

    private func matchingItems(_ searchText: String, in items: [ItemModel]) async -> [ItemModel] {
        if searchText.isEmpty {
            return items
        }

        if searchText.hasPrefix("#") {
            if let itemID = Int(searchText.dropFirst()),
               let item = items.first(where: { $0.id == itemID }) {
                return [item]
            } else {
                return []
            }
        }

        let filteredItems = items.filter { item in
            item.displayName.localizedStandardContains(searchText)
        }
        return filteredItems
    }
}

#Preview {
    @Previewable @State var selection: ItemModel? = nil

    CharacterEquipmentListView(category: .headTop, selection: $selection)
        .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
