//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<StatusChangeProvider>

    var body: some View {
        DatabaseView(database: database) { statusChanges in
            ResponsiveView {
                List(statusChanges) { statusChange in
                    NavigationLink(value: statusChange) {
                        Text(statusChange.status)
                    }
                }
                .listStyle(.plain)
            } regular: {
                Table(statusChanges) {
                    TableColumn("Status") { statusChange in
                        HStack {
                            Text(statusChange.status)
                            NavigationLink(value: statusChange) {
                                Image(systemName: "info.circle")
                            }
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
    StatusChangeDatabaseView(database: .init(mode: .renewal, recordProvider: .statusChange))
}
