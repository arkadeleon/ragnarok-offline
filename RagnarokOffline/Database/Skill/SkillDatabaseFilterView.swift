//
//  SkillDatabaseFilterView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokConstants
import SwiftUI

struct SkillDatabaseFilterView: View {
    @Binding var filter: SkillDatabaseFilter

    @Environment(\.dismiss) private var dismiss

    private var gridItem: GridItem {
        GridItem(.adaptive(minimum: 140))
    }

    var body: some View {
        ScrollView() {
            LazyVStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableTypes, id: \.rawValue) { type in
                            SelectableButton(type.localizedName, isSelected: filter.type == type) {
                                filter.toggleType(type)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Type", table: "Database"))
                }

                Section {
                    LazyVGrid(columns: [gridItem], alignment: .leading) {
                        ForEach(filter.availableTargetTypes, id: \.rawValue) { targetType in
                            SelectableButton(targetType.localizedName, isSelected: filter.targetType == targetType) {
                                filter.toggleTargetType(targetType)
                            }
                        }
                    }
                } header: {
                    SectionHeaderView(LocalizedStringResource("Target Type", table: "Database"))
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
    @Previewable @State var filter = SkillDatabaseFilter()

    NavigationStack {
        SkillDatabaseFilterView(filter: $filter)
    }
}
