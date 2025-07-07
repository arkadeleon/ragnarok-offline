//
//  PetDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: DatabaseModel<PetProvider> {
        appModel.petDatabase
    }

    var body: some View {
        ImageGrid(database.filteredRecords) { pet in
            if let monster = pet.monster {
                NavigationLink(value: pet) {
                    MonsterGridCell(monster: monster, secondaryText: nil)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Pet Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview("Pre-Renewal Pet Database") {
    @Previewable @State var appModel = AppModel()
    appModel.petDatabase = DatabaseModel(mode: .prerenewal, recordProvider: .pet)

    return PetDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Pet Database") {
    @Previewable @State var appModel = AppModel()
    appModel.petDatabase = DatabaseModel(mode: .prerenewal, recordProvider: .pet)

    return PetDatabaseView()
        .environment(appModel)
}
