//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import RODatabase
import SwiftUI

struct SkillDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .skill)

    var body: some View {
        DatabaseView(database: $database) { skills in
            ResponsiveView {
                List(skills) { skill in
                    NavigationLink(value: skill) {
                        SkillCell(skill: skill)
                    }
                }
                .listStyle(.plain)
            } regular: {
                List(skills) { skill in
                    NavigationLink(value: skill) {
                        HStack {
                            SkillIconView(skill: skill)
                                .frame(width: 40)
                            SkillNameView(skill: skill)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(skill.maxLevel.formatted())
                                .frame(width: 80, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                            Text(spCost(for: skill))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        } empty: {
            ContentUnavailableView("No Skills", systemImage: "arrow.up.heart.fill")
        }
        .navigationTitle("Skill Database")
    }

    private func spCost(for skill: Skill) -> String {
        guard let spCost = skill.requires?.spCost else {
            return ""
        }

        switch spCost {
        case .left(let spCost):
            return spCost.formatted()
        case .right(let spCost):
            return spCost.compactMap(String.init).joined(separator: " / ")
        }
    }
}

#Preview {
    SkillDatabaseView()
}
