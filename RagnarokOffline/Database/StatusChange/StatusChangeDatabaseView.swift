//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: DatabaseModel<StatusChangeProvider> {
        appModel.statusChangeDatabase
    }

    var body: some View {
        AdaptiveView {
            List(database.filteredRecords) { statusChange in
                NavigationLink(value: statusChange) {
                    StatusChangeCell(statusChange: statusChange)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { statusChange in
                NavigationLink(value: statusChange) {
                    StatusChangeCell(statusChange: statusChange)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Status Change Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "moon.zzz.fill")
        }
    }
}

#Preview("Pre-Renewal Status Change Database") {
    @Previewable @State var appModel = AppModel()
    appModel.statusChangeDatabase = DatabaseModel(mode: .prerenewal, recordProvider: .statusChange)

    return StatusChangeDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Status Change Database") {
    @Previewable @State var appModel = AppModel()
    appModel.statusChangeDatabase = DatabaseModel(mode: .prerenewal, recordProvider: .statusChange)

    return StatusChangeDatabaseView()
        .environment(appModel)
}
