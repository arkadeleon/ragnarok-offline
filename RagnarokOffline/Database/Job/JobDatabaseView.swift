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
                ForEach(jobs) { job in
                    NavigationLink(value: job) {
                        JobGridCell(job: job)
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
