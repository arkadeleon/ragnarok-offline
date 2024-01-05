//
//  JobDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaMap

struct JobDatabaseView: View {
    @State private var searchText = ""
    @State private var allRecords = [RAJob]()
    @State private var filteredRecords = [RAJob]()

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 32) {
                ForEach(filteredRecords, id: \.jobID) { job in
                    NavigationLink {
                        JobDetailView(job: job)
                    } label: {
                        JobGridCell(job: job)
                    }
                }
            }
            .padding(32)
        }
        .searchable(text: $searchText)
        .navigationTitle(RAJobDatabase.shared.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                allRecords = RAJobDatabase.shared.allRecords()
                filterRecords()
            }
        }
        .onSubmit(of: .search) {
            filterRecords()
        }
        .onChange(of: searchText) { _ in
            filterRecords()
        }
    }

    private func filterRecords() {
        if searchText.isEmpty {
            filteredRecords = allRecords
        } else {
            filteredRecords = allRecords.filter { job in
                job.jobName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    JobDatabaseView()
}
