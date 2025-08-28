//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @Environment(DatabaseModel<SkillProvider>.self) private var database

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
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(skill.maxLevel.formatted())
                            .frame(width: 80, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(skill.spCost)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Skill Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "arrow.up.heart.fill")
        }
        .task {
            await database.fetchRecords()
            await database.recordProvider.prefetchRecords(database.records)
        }
    }
}

#Preview("Pre-Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .skill))
}

#Preview("Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .skill))
}
