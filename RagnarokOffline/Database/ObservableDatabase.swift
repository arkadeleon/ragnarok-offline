//
//  ObservableDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import Combine
import rAthenaCommon

protocol DatabaseRecordProvider {
    associatedtype Record

    func records(for mode: ServerMode) async throws -> [Record]
    func records(matching searchText: String, in records: [Record]) -> [Record]
}

@MainActor
class ObservableDatabase<RecordProvider>: NSObject, ObservableObject where RecordProvider: DatabaseRecordProvider {
    let mode: ServerMode
    let recordProvider: RecordProvider

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var records: [RecordProvider.Record] = []
    @Published var filteredRecords: [RecordProvider.Record] = []

    init(mode: ServerMode, recordProvider: RecordProvider) {
        self.mode = mode
        self.recordProvider = recordProvider
    }

    func fetchRecords() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            records = try await recordProvider.records(for: mode)

            filterRecords()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterRecords() {
        if searchText.isEmpty {
            filteredRecords = records
        } else {
            filteredRecords = recordProvider.records(matching: searchText, in: records)
        }
    }
}
