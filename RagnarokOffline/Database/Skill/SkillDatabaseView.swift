//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .skill)

    var body: some View {
        AdaptiveView {
            List(database.filteredRecords) { skill in
                NavigationLink(value: skill) {
                    SkillCell(skill: skill)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { skill in
                NavigationLink(value: skill) {
                    HStack {
                        SkillIconImageView(skill: skill)
                            .frame(width: 40)
                        Text(skill.displayName)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Text(skill.maxLevel.formatted())
                            .frame(width: 80, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(skill.spCost)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Skill Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Results", systemImage: "arrow.up.heart.fill")
        }
    }
}

#Preview {
    SkillDatabaseView()
}
