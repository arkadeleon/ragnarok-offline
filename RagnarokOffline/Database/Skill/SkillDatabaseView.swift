//
//  SkillDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import SwiftUI

struct SkillDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<SkillProvider>

    var body: some View {
        DatabaseView(database: database) { skills in
            ResponsiveView {
                List(skills) { skill in
                    NavigationLink(value: skill) {
                        SkillCell(skill: skill)
                    }
                }
                .listStyle(.plain)
            } regular: {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(skills) { skill in
                            NavigationLink(value: skill) {
                                SkillCell(skill: skill)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Skill Database")
    }
}

#Preview {
    SkillDatabaseView(database: .init(mode: .renewal, recordProvider: .skill))
}
