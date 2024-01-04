//
//  MonsterDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct MonsterDetailView: View {
    let monster: RAMonster

    var body: some View {
        List {
            DatabaseRecordImage {
                await ClientResourceManager.shared.animatedMonsterImage(monster.monsterID)
            }
            .frame(width: 150, height: 150)

            Section("Info") {
                DatabaseRecordField(name: "ID", value: "#\(monster.monsterID)")
                DatabaseRecordField(name: "Aegis Name", value: monster.aegisName)
                DatabaseRecordField(name: "Name", value: monster.name)
                DatabaseRecordField(name: "Level", value: "\(monster.level)")
                DatabaseRecordField(name: "HP", value: "\(monster.hp)")
                DatabaseRecordField(name: "SP", value: "\(monster.sp)")
            }
        }
        .listStyle(.plain)
        .navigationTitle(monster.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MonsterDetailView(monster: RAMonster())
}
