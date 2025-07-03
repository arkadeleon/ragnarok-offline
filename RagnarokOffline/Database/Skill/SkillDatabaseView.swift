//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: ObservableDatabase<SkillProvider> {
        appModel.skillDatabase
    }

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
    }
}

#Preview("Pre-Renewal Skill Database") {
    @Previewable @State var appModel = AppModel()
    appModel.skillDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .skill)

    return SkillDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Skill Database") {
    @Previewable @State var appModel = AppModel()
    appModel.skillDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .skill)

    return SkillDatabaseView()
        .environment(appModel)
}
