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

    @Environment(DatabaseModel.self) private var database

    @Namespace private var equipmentNamespace

    @State private var isPicking = false
    @State private var searchText = ""
    @State private var items: [ItemModel] = []
    @State private var filteredItems: [ItemModel] = []

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
            .matchedTransitionSource(id: "equipment", in: equipmentNamespace)
        }
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                itemList
            }
            .presentationSizing(.form)
            #if os(macOS)
            .navigationTransition(.automatic)
            #else
            .navigationTransition(.zoom(sourceID: "equipment", in: equipmentNamespace))
            #endif
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
            }
        }
        .listStyle(.plain)
        .navigationTitle(titleKey)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    isPicking = false
                }
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
                items = database.items.filter(predicate)
            }

            filteredItems = await items(matching: searchText, in: items)
        }
    }

    init(_ titleKey: LocalizedStringKey, predicate: @escaping (ItemModel) -> Bool, selection: Binding<ItemModel?>) {
        self.titleKey = titleKey
        self.predicate = predicate
        _selection = selection
    }

    private func items(matching searchText: String, in items: [ItemModel]) async -> [ItemModel] {
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

    List {
        CharacterEquipmentPicker(
            "Items",
            predicate: { item in
                true
            },
            selection: $selection
        )
    }
    .environment(DatabaseModel(mode: .renewal))
}
