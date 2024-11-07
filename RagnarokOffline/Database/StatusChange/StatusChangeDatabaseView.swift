//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .statusChange)

    var body: some View {
        ResponsiveView {
            List(database.filteredRecords) { statusChange in
                NavigationLink(value: statusChange) {
                    Text(statusChange.displayName)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { statusChange in
                NavigationLink(value: statusChange) {
                    HStack {
                        Text(statusChange.displayName)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Text(statusChange.icon.stringValue)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Status Change Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Status Changes", systemImage: "moon.zzz.fill")
        }
    }
}

#Preview {
    StatusChangeDatabaseView()
}
