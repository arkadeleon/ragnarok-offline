//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .job)

    var body: some View {
        ImageGrid {
            ForEach(database.filteredRecords) { job in
                NavigationLink(value: job) {
                    JobGridCell(job: job)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Job Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Jobs", systemImage: "person.fill")
        }
    }
}

#Preview {
    JobDatabaseView()
}
