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

            if let skill = statusChange.durationLookupSkill {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        NavigationLink(value: skill) {
                            SkillCell(skill: skill)
                        }
                    }
                } header: {
                    Text("Duration Lookup", tableName: "Database")
                }
            } else if let durationLookup = statusChange.durationLookup {
                DatabaseRecordSectionView(text: durationLookup) {
                    Text("Duration Lookup", tableName: "Database")
                }
            }

            if !statusChange.fail.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(statusChange.fail) { statusChange in
                            NavigationLink(value: statusChange) {
                                StatusChangeCell(statusChange: statusChange)
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
                                StatusChangeCell(statusChange: statusChange)
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
                                StatusChangeCell(statusChange: statusChange)
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
                                StatusChangeCell(statusChange: statusChange)
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
