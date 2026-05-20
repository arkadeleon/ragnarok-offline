//
//  StatusChangeDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import SwiftUI

struct StatusChangeDetailView: View {
    var statusChange: StatusChangeModel

    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordDetailView {
            DatabaseRecordSectionView(attributes: statusChange.attributes) {
                Text("Info", tableName: "Database")
            }

            if !statusChange.fail.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(statusChange.fail) { statusChange in
                            NavigationLink(value: statusChange) {
                                Text(statusChange.displayName)
                            }
                        }
                    }
                } header: {
                    Text("Fail", tableName: "Database")
                }
            }

            if !statusChange.endOnStart.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(statusChange.endOnStart) { statusChange in
                            NavigationLink(value: statusChange) {
                                Text(statusChange.displayName)
                            }
                        }
                    }
                } header: {
                    Text("End on Start", tableName: "Database")
                }
            }

            if !statusChange.endReturn.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(statusChange.endReturn) { statusChange in
                            NavigationLink(value: statusChange) {
                                Text(statusChange.displayName)
                            }
                        }
                    }
                } header: {
                    Text("End Return", tableName: "Database")
                }
            }

            if !statusChange.endOnEnd.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(statusChange.endOnEnd) { statusChange in
                            NavigationLink(value: statusChange) {
                                Text(statusChange.displayName)
                            }
                        }
                    }
                } header: {
                    Text("End on End", tableName: "Database")
                }
            }

            if let localizedDescription = statusChange.localizedDescription {
                DatabaseRecordSectionView(text: localizedDescription) {
                    Text("Description", tableName: "Database")
                }
            }

            if let script = statusChange.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: script, monospaced: true) {
                    Text("Script", tableName: "Database")
                }
            }
        }
        .navigationTitle(statusChange.displayName)
        .task {
            await statusChange.fetchDetail(database: database)
        }
    }
}
