//
//  ObservableDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import Observation
import RODatabase

protocol DatabaseRecordProvider {
    associatedtype Record

    func records(for mode: DatabaseMode) async throws -> [Record]
    func moreRecords(for mode: DatabaseMode) async throws -> [Record]

    func records(matching searchText: String, in records: [Record]) async -> [Record]
}

extension DatabaseRecordProvider {
    func moreRecords(for mode: DatabaseMode) async throws -> [Record] {
        []
    }
}

@Observable 
class ObservableDatabase<RecordProvider> where RecordProvider: DatabaseRecordProvider {
    let mode: DatabaseMode
    let recordProvider: RecordProvider

    var loadStatus: LoadStatus = .notYetLoaded
    var searchText = ""
    var records: [RecordProvider.Record] = []
    var filteredRecords: [RecordProvider.Record] = []

    init(mode: DatabaseMode, recordProvider: RecordProvider) {
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

            await filterRecords()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }

        if !records.isEmpty, let moreRecords = try? await recordProvider.moreRecords(for: mode) {
            records += moreRecords
        }
    }

    func filterRecords() async {
        if searchText.isEmpty {
            filteredRecords = records
        } else {
            filteredRecords = await recordProvider.records(matching: searchText, in: records)
        }
    }
}
