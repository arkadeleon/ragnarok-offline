//
//  CharacterEquipmentPicker.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/26.
//

import SwiftUI

struct CharacterEquipmentPicker: View {
    var titleKey: LocalizedStringKey
    var predicate: (ItemModel) -> Bool
    @Binding var selection: ItemModel?

    @Environment(DatabaseModel<ItemProvider>.self) private var itemDatabase

    @State private var isPicking = false
    @State private var searchText = ""
    @State private var items: [ItemModel] = []

    var body: some View {
        LabeledContent(titleKey) {
            Button {
                isPicking = true
            } label: {
                if let selection {
                    Text(selection.displayName)
                } else {
                    Text("None")
                }
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                itemList
            }
            .presentationSizing(.form)
        }
    }

    @ViewBuilder private var itemList: some View {
        List {
            Button {
                selection = nil
                isPicking = false
            } label: {
                HStack {
                    Text("None")
                        .foregroundStyle(Color.primary)

                    Spacer()

                    if selection == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.link)
                    }
                }
            }
            .buttonStyle(.plain)

            ForEach(filteredItems) { item in
                Button {
                    selection = item
                    isPicking = false
                } label: {
                    HStack {
                        ItemCell(item: item)

                        if selection == item {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.link)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle(titleKey)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    isPicking = false
                }
            }
        }
        .overlay {
            if items.isEmpty {
                ProgressView()
            }
        }
        .searchable(text: $searchText)
        .task {
            await itemDatabase.fetchRecords()

            let items = itemDatabase.records
            self.items = items.filter(predicate)
        }
    }

    private var filteredItems: [ItemModel] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { item in
                item.displayName.localizedStandardContains(searchText)
            }
        }
    }

    init(_ titleKey: LocalizedStringKey, predicate: @escaping (ItemModel) -> Bool, selection: Binding<ItemModel?>) {
        self.titleKey = titleKey
        self.predicate = predicate
        _selection = selection
    }
}

#Preview {
    @Previewable @State var selection: ItemModel? = nil

    CharacterEquipmentPicker(
        "Items",
        predicate: { item in
            true
        },
        selection: $selection
    )
    .environment(DatabaseModel(mode: .renewal, recordProvider: .item))
}
