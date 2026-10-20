//
//  JobLevelTableView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct JobLevelTableView: View {
    var job: JobModel

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(job.jobLevels) { levelStats in
                        HStack {
                            Text(levelStats.level.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text(levelStats.jobExp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.bonusStats)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                        .levelTableRow(level: levelStats.level)
                    }
                } header: {
                    HStack {
                        Text("Job Level", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("Job Exp", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("Bonus Stats", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .levelTableHeader()
                }
            }
            .padding(.horizontal, hSpacing(sizeClass))
        }
        .background(.background)
        .navigationTitle(Text("Job Levels", tableName: "Database"))
    }
}
