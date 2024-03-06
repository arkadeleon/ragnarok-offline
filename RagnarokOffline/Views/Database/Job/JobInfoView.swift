//
//  JobInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct JobInfoView: View {
    let database: Database
    let jobStats: JobStats

    typealias BaseLevelStats = (level: Int, baseExp: Int, baseHp: Int, baseSp: Int)
    typealias JobLevelStats = (level: Int, jobExp: Int, bonusStats: String)

    var body: some View {
        ScrollView {
            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)]) {
                    LabeledContent("Max Weight", value: "\(jobStats.maxWeight)")
                    LabeledContent("HP Factor", value: "\(jobStats.hpFactor)")
                    LabeledContent("HP Increase", value: "\(jobStats.hpIncrease)")
                    LabeledContent("SP Increase", value: "\(jobStats.spIncrease)")
                }
            }

            DatabaseRecordInfoSection("Base ASPD") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)]) {
                    ForEach(baseASPD, id: \.title) { field in
                        LabeledContent(field.title, value: field.value)
                    }
                }
            }

            DatabaseRecordInfoSection {
                Grid(verticalSpacing: 8) {
                    ForEach(baseLevels, id: \.level) { levelStats in
                        GridRow {
                            Text("\(levelStats.level + 1)")
                            Text("\(levelStats.baseExp)")
                                .foregroundColor(.secondary)
                            Text("\(levelStats.baseHp)")
                                .foregroundColor(.secondary)
                            Text("\(levelStats.baseSp)")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } header: {
                Grid {
                    GridRow {
                        Text("Base Level")
                        Text("Base Exp")
                        Text("Base HP")
                        Text("Base SP")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            DatabaseRecordInfoSection {
                Grid(verticalSpacing: 8) {
                    ForEach(jobLevels, id: \.level) { levelStats in
                        GridRow {
                            Text("\(levelStats.level + 1)")
                            Text("\(levelStats.jobExp)")
                                .foregroundColor(.secondary)
                            Text(levelStats.bonusStats)
                                .foregroundColor(.secondary)
                            Text("")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } header: {
                Grid {
                    GridRow {
                        Text("Job Level")
                        Text("Job Exp")
                        Text("Bonus Stats")
                        Text("")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle(jobStats.job.description)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var baseASPD: [DatabaseRecordField] {
        WeaponType.allCases.compactMap { weaponType in
            if let aspd = jobStats.baseASPD[weaponType] {
                (weaponType.description, "\(aspd)")
            } else {
                nil
            }
        }
    }

    private var baseLevels: [BaseLevelStats] {
        (0..<jobStats.maxBaseLevel).map { level in
            (level, jobStats.baseExp[level], jobStats.baseHp[level], jobStats.baseSp[level])
        }
    }

    private var jobLevels: [JobLevelStats] {
        (0..<jobStats.maxJobLevel).map { level in
            let bonusStats = Parameter.allCases.compactMap { parameter in
                if let value = jobStats.bonusStats[level][parameter], value > 0 {
                    return "\(parameter.description)(+\(value))"
                } else {
                    return nil
                }
            }.joined(separator: " ")
            return (level, jobStats.jobExp[level], bonusStats)
        }
    }
}
