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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    LabeledContent("Max Weight", value: "\(jobStats.maxWeight)")
                    LabeledContent("HP Factor", value: "\(jobStats.hpFactor)")
                    LabeledContent("HP Increase", value: "\(jobStats.hpIncrease)")
                    LabeledContent("SP Increase", value: "\(jobStats.spIncrease)")
                }
            }

            DatabaseRecordInfoSection("Base ASPD") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(baseASPD, id: \.title) { field in
                        LabeledContent(field.title, value: field.value)
                    }
                }
            }

            DatabaseRecordInfoSection {
                LazyVStack(spacing: 10) {
                    ForEach(baseLevels, id: \.level) { levelStats in
                        HStack {
                            Text("\(levelStats.level + 1)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text("\(levelStats.baseExp)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)

                            Text("\(levelStats.baseHp)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)

                            Text("\(levelStats.baseSp)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Base Level")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("Base Exp")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("Base HP")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("Base SP")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }

            DatabaseRecordInfoSection {
                LazyVStack(spacing: 10) {
                    ForEach(jobLevels, id: \.level) { levelStats in
                        HStack {
                            Text("\(levelStats.level + 1)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text("\(levelStats.jobExp)")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)

                            Text(levelStats.bonusStats)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)

                            Text("")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Job Level")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("Job Exp")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("Bonus Stats")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    Text("")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
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
