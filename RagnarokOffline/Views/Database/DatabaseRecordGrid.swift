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
    let columns: [GridItem]
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let insets: EdgeInsets
    let partitions: () async -> AsyncDatabaseRecordPartitions<Record>
    let filter: ([Record], String) -> [Record]
    let content: (Record) -> Content

    @State private var status: AsyncContentStatus<[Record]> = .notYetLoaded
    @State private var searchText = ""
    @State private var filteredRecords: [Record] = []

    var body: some View {
        AsyncContentView(status: status) { records in
            ScrollView {
                LazyVGrid(columns: columns, alignment: alignment, spacing: spacing) {
                    ForEach(filteredRecords) { record in
                        content(record)
                    }
                }
                .padding(insets)
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                filterRecords()
            }
            .onChange(of: searchText) { _ in
                filterRecords()
            }
        }
        .task {
            await load()
        }
    }

    init(columns: [GridItem], 
         alignment: HorizontalAlignment,
         spacing: CGFloat,
         insets: EdgeInsets,
         partitions: @escaping () async -> AsyncDatabaseRecordPartitions<Record>,
         filter: @escaping ([Record], String) -> [Record],
         @ViewBuilder content: @escaping (Record) -> Content) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        self.insets = insets
        self.partitions = partitions
        self.filter = filter
        self.content = content
    }

    private func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            let partitions = await partitions()
            for try await partition in partitions {
                switch status {
                case .loaded(let records):
                    status = .loaded(records + partition.records)
                    filterRecords()
                default:
                    status = .loaded(partition.records)
                    filterRecords()
                }
            }
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
