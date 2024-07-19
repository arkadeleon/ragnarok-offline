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
        DatabaseView(database: $database) { jobs in
            ImageGrid {
                ForEach(jobs) { jobStats in
                    NavigationLink(value: jobStats) {
                        JobGridCell(jobStats: jobStats)
                    }
                    .buttonStyle(.plain)
                }
            }
        } empty: {
            ContentUnavailableView("No Jobs", systemImage: "person.fill")
        }
        .navigationTitle("Job Database")
    }
}

#Preview {
    JobDatabaseView()
}
