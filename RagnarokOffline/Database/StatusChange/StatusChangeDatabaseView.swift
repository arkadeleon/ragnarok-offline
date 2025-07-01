//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @Environment(ObservableDatabase<StatusChangeProvider>.self) private var database

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
    StatusChangeDatabaseView()
        .environment(ObservableDatabase(mode: .prerenewal, recordProvider: .statusChange))
}

#Preview("Renewal Status Change Database") {
    StatusChangeDatabaseView()
        .environment(ObservableDatabase(mode: .renewal, recordProvider: .statusChange))
}
