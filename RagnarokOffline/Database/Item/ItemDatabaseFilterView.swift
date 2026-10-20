//
//  ItemDatabaseFilterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/18.
//

import RagnarokConstants
import SwiftUI

struct ItemDatabaseFilterView: View {
    @Binding var filter: ItemDatabaseFilter

    @Environment(\.dismiss) private var dismiss

    private var gridItem: GridItem {
        GridItem(.adaptive(minimum: 140))
    }

    var body: some View {
        ScrollView() {
            LazyVStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableItemTypes, id: \.rawValue) { itemType in
                            SelectableButton(itemType.localizedName, isSelected: filter.itemType == itemType) {
                                filter.toggleItemType(itemType)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Type", table: "Database"))
                }

                if filter.itemType == .weapon {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableWeaponTypes, id: \.rawValue) { weaponType in
                                SelectableButton(weaponType.localizedName, isSelected: filter.weaponType == weaponType) {
                                    filter.toggleWeaponType(weaponType)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Weapon Type", table: "Database"))
                            .padding(.top)
                    }
                }

                if filter.itemType == .ammo {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableAmmoTypes, id: \.rawValue) { ammoType in
                                SelectableButton(ammoType.localizedName, isSelected: filter.ammoType == ammoType) {
                                    filter.toggleAmmoType(ammoType)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Ammo Type", table: "Database"))
                            .padding(.top)
                    }
                }

                if filter.itemType == .card {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableCardTypes, id: \.rawValue) { cardType in
                                SelectableButton(cardType.localizedName, isSelected: filter.cardType == cardType) {
                                    filter.toggleCardType(cardType)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Card Type", table: "Database"))
                            .padding(.top)
                    }
                }

                if filter.itemType == .armor || filter.itemType == .card || filter.itemType == .shadowgear {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableLocations, id: \.rawValue) { location in
                                SelectableButton(location.localizedName, isSelected: filter.locations.contains(location)) {
                                    filter.toggleLocation(location)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Locations", table: "Database"))
                            .padding(.top)
                    }
                }

                if filter.itemType == .weapon || filter.itemType == .armor || filter.itemType == .shadowgear {
                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableSlots, id: \.self) { slots in
                                SelectableButton(slots.formatted(), isSelected: filter.slots == slots) {
                                    filter.toggleSlots(slots)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Slots", table: "Database"))
                            .padding(.top)
                    }

                    Section {
                        LazyVGrid(columns: [gridItem], alignment: .leading) {
                            ForEach(filter.availableJobs, id: \.rawValue) { job in
                                SelectableButton(job.localizedName.map { String(localized: $0) } ?? job.stringValue, isSelected: filter.job == job) {
                                    filter.toggleJob(job)
                                }
                            }
                        }
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Jobs", table: "Database"))
                            .padding(.top)
                    }

                    Section {
                        TextField(value: $filter.baseLevel, format: .number) {
                            Text("Base Level", tableName: "Database")
                        }
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 140)
                    } header: {
                        SectionHeaderView(LocalizedStringResource("Equip Level", table: "Database"))
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
    @Previewable @State var filter = ItemDatabaseFilter()

    NavigationStack {
        ItemDatabaseFilterView(filter: $filter)
    }
}
