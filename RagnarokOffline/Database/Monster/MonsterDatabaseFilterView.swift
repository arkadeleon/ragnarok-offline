//
//  MonsterDatabaseFilterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import SwiftUI

struct MonsterDatabaseFilterView: View {
    var filter: MonsterDatabaseFilter

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
                        ForEach(filter.availableSizes, id: \.rawValue) { size in
                            SelectableButton(size.stringValue, isSelected: filter.size == size) {
                                filter.size = size
                            }
                        }
                    }
                } header: {
                    SectionHeaderView("Size")
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableRaces, id: \.rawValue) { race in
                            SelectableButton(race.localizedName, isSelected: filter.race == race) {
                                filter.race = race
                            }
                        }
                    }
                } header: {
                    SectionHeaderView("Race")
                        .padding(.top)
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableElements, id: \.rawValue) { element in
                            SelectableButton(element.stringValue, isSelected: filter.element == element) {
                                filter.element = element
                            }
                        }
                    }
                } header: {
                    SectionHeaderView("Element")
                        .padding(.top)
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
    MonsterDatabaseFilterView(filter: MonsterDatabaseFilter())
}
