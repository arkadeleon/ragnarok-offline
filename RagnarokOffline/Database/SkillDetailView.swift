//
//  SkillDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct SkillDetailView: View {
    @EnvironmentObject var database: Database

    let skill: RASkill

    var body: some View {
        List {
            ForEach(skill.attributes, id: \.name) { attribute in
                HStack {
                    Text(attribute.name)
                    Spacer()
                    Text(attribute.value)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(skill.skillDescription)
    }
}
