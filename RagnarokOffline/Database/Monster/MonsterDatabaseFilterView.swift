//
//  MonsterDatabaseFilterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import RagnarokConstants
import SwiftUI

struct MonsterDatabaseFilterView: View {
    @Binding var filter: MonsterDatabaseFilter

    @Environment(\.dismiss) private var dismiss

    private var gridItem: GridItem {
        GridItem(.adaptive(minimum: 140))
    }

    var body: some View {
        ScrollView() {
            LazyVStack(alignment: .leading) {
                Section {
                    HStack {
                        TextField(value: $filter.minimumLevel, format: .number) {
                            Text("Min", tableName: "Database")
                        }
                        Text(verbatim: "–")
                        TextField(value: $filter.maximumLevel, format: .number) {
                            Text("Max", tableName: "Database")
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)
                } header: {
                    SectionHeaderView(LocalizedStringResource("Level", table: "Database"))
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableSizes, id: \.rawValue) { size in
                            SelectableButton(size.localizedName, isSelected: filter.size == size) {
                                filter.toggleSize(size)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Size", table: "Database"))
                        .padding(.top)
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableRaces, id: \.rawValue) { race in
                            SelectableButton(race.localizedName, isSelected: filter.race == race) {
                                filter.toggleRace(race)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Race", table: "Database"))
                        .padding(.top)
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableElements, id: \.rawValue) { element in
                            SelectableButton(element.localizedName, isSelected: filter.element == element) {
                                filter.toggleElement(element)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Element", table: "Database"))
                        .padding(.top)
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableMonsterClasses, id: \.rawValue) { monsterClass in
                            SelectableButton(monsterClass.localizedName, isSelected: filter.monsterClass == monsterClass) {
                                filter.toggleMonsterClass(monsterClass)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Class", table: "Database"))
                        .padding(.top)
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        SelectableButton(MonsterMode.mvp.localizedName, isSelected: filter.isMVPOnly) {
                            filter.isMVPOnly.toggle()
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Modes", table: "Database"))
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
    @Previewable @State var filter = MonsterDatabaseFilter()

    MonsterDatabaseFilterView(filter: $filter)
}
