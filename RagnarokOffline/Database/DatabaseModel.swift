//
//  DatabaseModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import Observation
import RODatabase

@MainActor
protocol DatabaseRecordProvider {
    associatedtype Record: Identifiable

    func records(for mode: DatabaseMode) async -> [Record]
    func moreRecords(for mode: DatabaseMode) async -> [Record]

    func records(matching searchText: String, in records: [Record]) async -> [Record]
}

extension DatabaseRecordProvider {
    func moreRecords(for mode: DatabaseMode) async -> [Record] {
        []
    }
}

@MainActor
@Observable
final class DatabaseModel<RecordProvider> where RecordProvider: DatabaseRecordProvider {
    typealias Record = RecordProvider.Record

    let mode: DatabaseMode
    let recordProvider: RecordProvider

    var loadStatus: LoadStatus = .notYetLoaded
    var searchText = ""
    var records: [Record] = []
    var recordsByID: [Record.ID : Record] = [:]
    var filteredRecords: [Record] = []

    init(mode: DatabaseMode, recordProvider: RecordProvider) {
        self.mode = mode
        self.recordProvider = recordProvider
    }

    func fetchRecords() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        records = await recordProvider.records(for: mode)
        recordsByID = Dictionary(
            records.map({ ($0.id, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
        await filterRecords()

        loadStatus = .loaded

        let moreRecords = await recordProvider.moreRecords(for: mode)
        if !records.isEmpty, !moreRecords.isEmpty {
            records += moreRecords
            recordsByID = Dictionary(
                records.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
            await filterRecords()
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
