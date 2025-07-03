//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: ObservableDatabase<MonsterProvider> {
        appModel.monsterDatabase
    }

    var body: some View {
        ImageGrid(database.filteredRecords) { monster in
            NavigationLink(value: monster) {
                MonsterGridCell(monster: monster, secondaryText: nil)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Monster Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview("Pre-Renewal Monster Database") {
    @Previewable @State var appModel = AppModel()
    appModel.monsterDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .monster)

    return MonsterDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Monster Database") {
    @Previewable @State var appModel = AppModel()
    appModel.monsterDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monster)

    return MonsterDatabaseView()
        .environment(appModel)
}
