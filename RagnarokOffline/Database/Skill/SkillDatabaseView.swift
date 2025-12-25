//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredSkills: [SkillModel] = []

    var body: some View {
        AdaptiveView {
            List(filteredSkills) { skill in
                NavigationLink(value: skill) {
                    SkillCell(skill: skill)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(filteredSkills) { skill in
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
        .background(.background)
        .navigationTitle("Skill Database")
        .adaptiveSearch(text: $searchText)
        .overlay {
            if database.skills.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredSkills.isEmpty {
                ContentUnavailableView("No Results", systemImage: "arrow.up.heart.fill")
            }
        }
        .task(id: "\(searchText)") {
            await database.fetchSkills()
            filteredSkills = await skills(matching: searchText, in: database.skills)
        }
    }

    private func skills(matching searchText: String, in skills: [SkillModel]) async -> [SkillModel] {
        if searchText.isEmpty {
            return skills
        }

        if searchText.hasPrefix("#") {
            if let skillID = Int(searchText.dropFirst()),
               let skill = skills.first(where: { $0.id == skillID }) {
                return [skill]
            } else {
                return []
            }
        }

        let filteredSkills = skills.filter { skill in
            skill.displayName.localizedStandardContains(searchText)
        }
        return filteredSkills
    }
}

#Preview("Pre-Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Skill Database") {
    NavigationStack {
        SkillDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal))
}
