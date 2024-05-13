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
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(jobs) { jobStats in
                        NavigationLink(value: jobStats) {
                            JobGridCell(jobStats: jobStats)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Job Database")
    }
}

#Preview {
    JobDatabaseView()
}
