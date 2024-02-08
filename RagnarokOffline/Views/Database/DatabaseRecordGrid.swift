//
//  DatabaseRecordGrid.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/15.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct DatabaseRecordGrid<Record, Content>: View where Record: Identifiable, Content: View {
    let fetch: () async throws -> [Record]
    let filter: ([Record], String) -> [Record]
    let content: (Record) -> Content

    private enum Status {
        case notYetLoaded
        case loading
        case loaded([Record])
        case failed(Error)
    }

    @State private var status: Status = .notYetLoaded
    @State private var searchText = ""
    @State private var filteredRecords: [Record] = []

    var body: some View {
        ZStack {
            switch status {
            case .notYetLoaded:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 32) {
                        ForEach(filteredRecords) { record in
                            content(record)
                        }
                    }
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
                }
                .searchable(text: $searchText)
                .onSubmit(of: .search) {
                    filterRecords()
                }
                .onChange(of: searchText) { _ in
                    filterRecords()
                }
            case .failed(let error):
                Text(error.localizedDescription)
            }
        }
        .task {
            await load()
        }
    }

    init(fetch: @escaping () async throws -> [Record], filter: @escaping ([Record], String) -> [Record], @ViewBuilder content: @escaping (Record) -> Content) {
        self.fetch = fetch
        self.filter = filter
        self.content = content
    }

    private func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            let records = try await fetch()
            status = .loaded(records)
            filterRecords()
        } catch {
            status = .failed(error)
        }
    }

    private func filterRecords() {
        guard case .loaded(let records) = status else {
            return
        }

        if searchText.isEmpty {
            filteredRecords = records
        } else {
            filteredRecords = filter(records, searchText)
        }
    }
}

#Preview {
    DatabaseRecordGrid {
        Job.allCases
    } filter: { jobs, searchText in
        jobs.filter { job in
            job.description.localizedCaseInsensitiveContains(searchText)
        }
    } content: { job in
        Text(job.description)
    }
}
