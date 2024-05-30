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
                    TableColumn("Name") { statusChange in
                        NavigationLink(value: statusChange) {
                            Text(statusChange.status)
                        }
                    }
                    TableColumn("Icon", value: \.icon)
                }
            }
        }
        .navigationTitle("Status Change Database")
    }
}

#Preview {
    StatusChangeDatabaseView()
}
