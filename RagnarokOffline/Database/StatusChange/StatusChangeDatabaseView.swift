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
                Table(statusChanges) {
                    TableColumn("Status", value: \.status)
                    TableColumn("Icon", value: \.icon)
                    TableColumn("") { statusChange in
                        NavigationLink(value: statusChange) {
                            Image(systemName: "info.circle")
                        }
                    }
                    .width(24)
                }
            }
        }
        .navigationTitle("Status Change Database")
    }
}

#Preview {
    StatusChangeDatabaseView()
}
