//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: DatabaseModel<JobProvider> {
        appModel.jobDatabase
    }

    var body: some View {
        ImageGrid(database.filteredRecords) { job in
            NavigationLink(value: job) {
                JobGridCell(job: job)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Job Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "person.fill")
        }
    }
}

#Preview("Pre-Renewal Job Database") {
    @Previewable @State var appModel = AppModel()
    appModel.jobDatabase = DatabaseModel(mode: .prerenewal, recordProvider: .job)

    return JobDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Job Database") {
    @Previewable @State var appModel = AppModel()
    appModel.jobDatabase = DatabaseModel(mode: .renewal, recordProvider: .job)

    return JobDatabaseView()
        .environment(appModel)
}
