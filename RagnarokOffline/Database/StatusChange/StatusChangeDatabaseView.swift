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
        DatabaseView(database: $database) { statusChanges in
            ResponsiveView {
                List(statusChanges) { statusChange in
                    NavigationLink(value: statusChange) {
                        Text(statusChange.status)
                    }
                }
                .listStyle(.plain)
            } regular: {
                List(statusChanges) { statusChange in
                    NavigationLink(value: statusChange) {
                        HStack {
                            Text(statusChange.status)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(statusChange.icon)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        } empty: {
            ContentUnavailableView("No Status Changes", systemImage: "moon.zzz.fill")
        }
        .navigationTitle("Status Change Database")
    }
}

#Preview {
    StatusChangeDatabaseView()
}
