//
//  StatusChangeInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import RODatabase
import SwiftUI

struct StatusChangeInfoView: View {
    var mode: DatabaseMode
    var statusChange: StatusChange

    @State private var fail: [StatusChange] = []
    @State private var endOnStart: [StatusChange] = []
    @State private var endReturn: [StatusChange] = []
    @State private var endOnEnd: [StatusChange] = []

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                DatabaseRecordSectionView("Info", spacing: 10) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                        ForEach(attributes) { attribute in
                            LabeledContent {
                                Text(attribute.value)
                            } label: {
                                Text(attribute.name)
                            }
                        }
                    }
                }

                if !fail.isEmpty {
                    DatabaseRecordSectionView("Fail", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(fail, id: \.status) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.status.stringValue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !endOnStart.isEmpty {
                    DatabaseRecordSectionView("End on Start", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(endOnStart, id: \.status) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.status.stringValue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !endReturn.isEmpty {
                    DatabaseRecordSectionView("End Return", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(endReturn, id: \.status) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.status.stringValue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !endOnEnd.isEmpty {
                    DatabaseRecordSectionView("End on End", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(endOnEnd, id: \.status) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.status.stringValue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(statusChange.status.stringValue)
        .task {
            await loadStatusChangeInfo()
        }
    }

    private var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "Status", value: statusChange.status.stringValue))
        attributes.append(.init(name: "Icon", value: statusChange.icon.stringValue))

        return attributes
    }

    nonisolated private func loadStatusChangeInfo() async {
        let database = StatusChangeDatabase.database(for: mode)

        let fail = try? await database.statusChanges(forIDs: Array(statusChange.fail ?? []))
        let endOnStart = try? await database.statusChanges(forIDs: Array(statusChange.endOnStart ?? []))
        let endReturn = try? await database.statusChanges(forIDs: Array(statusChange.endReturn ?? []))
        let endOnEnd = try? await database.statusChanges(forIDs: Array(statusChange.endOnEnd ?? []))

        await MainActor.run {
            self.fail = fail ?? []
            self.endOnStart = endOnStart ?? []
            self.endReturn = endReturn ?? []
            self.endOnEnd = endOnEnd ?? []
        }
    }
}
