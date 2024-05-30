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
        DatabaseView(database: $database) { skills in
            ResponsiveView {
                List(skills) { skill in
                    NavigationLink(value: skill) {
                        SkillCell(skill: skill)
                    }
                }
                .listStyle(.plain)
            } regular: {
                Table(skills) {
                    TableColumn("") { skill in
                        SkillIconView(skill: skill)
                    }
                    .width(40)
                    TableColumn("Name") { skill in
                        NavigationLink(value: skill) {
                            SkillNameView(skill: skill)
                        }
                    }
                    TableColumn("Max Level") { skill in
                        Text("\(skill.maxLevel)")
                    }
                    .width(100)
                    TableColumn("SP Cost") { skill in
                        skill.requires?.spCost.map { spCost in
                            Text("\(spCost)")
                        } right: { spCost in
                            Text(spCost.compactMap(String.init).joined(separator: " / "))
                        }
                    }
                }
            }
        }
        .navigationTitle("Skill Database")
    }
}

#Preview {
    SkillDatabaseView()
}
