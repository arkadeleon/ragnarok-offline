//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @Environment(DatabaseModel<StatusChangeProvider>.self) private var database

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
        .task {
            await database.fetchRecords()
        }
    }
}

#Preview("Pre-Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal, recordProvider: .statusChange))
}

#Preview("Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal, recordProvider: .statusChange))
}
