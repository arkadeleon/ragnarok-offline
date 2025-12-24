//
//  ItemDatabaseFilterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/18.
//

import SwiftUI

struct ItemDatabaseFilterView: View {
    var filter: ItemDatabaseFilter

    @Environment(\.dismiss) private var dismiss

    private var gridItem: GridItem {
        GridItem(.adaptive(minimum: 140))
    }

    var body: some View {
        @Bindable var filter = filter

        ScrollView() {
            LazyVStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableItemTypes, id: \.rawValue) { itemType in
                            SelectableButton(itemType.localizedName, isSelected: filter.itemType == itemType) {
                                filter.itemType = itemType
                            }
                        }
                    }
                } header: {
                    SectionHeaderView("Type")
                }

                if filter.itemType == .weapon {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableWeaponTypes, id: \.rawValue) { weaponType in
                                SelectableButton(weaponType.localizedName, isSelected: filter.weaponType == weaponType) {
                                    filter.weaponType = weaponType
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView("Weapon Type")
                            .padding(.top)
                    }
                }

                if filter.itemType == .ammo {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableAmmoTypes, id: \.rawValue) { ammoType in
                                SelectableButton(ammoType.stringValue, isSelected: filter.ammoType == ammoType) {
                                    filter.ammoType = ammoType
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView("Ammo Type")
                            .padding(.top)
                    }
                }

                if filter.itemType == .card {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableCardTypes, id: \.rawValue) { cardType in
                                SelectableButton(cardType.stringValue, isSelected: filter.cardType == cardType) {
                                    filter.cardType = cardType
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView("Card Type")
                            .padding(.top)
                    }
                }

                if filter.itemType == .armor || filter.itemType == .card || filter.itemType == .shadowgear {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableLocations, id: \.rawValue) { location in
                                SelectableButton(location.stringValue, isSelected: filter.locations.contains(location)) {
                                    if filter.locations.contains(location) {
                                        filter.locations.remove(location)
                                    } else {
                                        filter.locations.insert(location)
                                    }
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView("Locations")
                            .padding(.top)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarResetButton {
                filter.reset()
            }
            ToolbarDoneButton {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItemDatabaseFilterView(filter: ItemDatabaseFilter())
    }
}
