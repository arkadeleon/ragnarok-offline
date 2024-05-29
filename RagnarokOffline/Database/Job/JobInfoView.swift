//
//  JobInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI
import rAthenaCommon
import ROClient
import RODatabase

struct JobInfoView: View {
    let mode: ServerMode
    let jobStats: JobStats

    typealias BaseLevelStats = (level: Int, baseExp: Int, baseHp: Int, baseSp: Int)
    typealias JobLevelStats = (level: Int, jobExp: Int, bonusStats: String)

    @State private var jobImage: CGImage?
    @State private var skills: [Skill] = []

    var body: some View {
        ScrollView {
            ZStack {
                if let jobImage {
                    Image(jobImage, scale: 1, label: Text(jobStats.job.description))
                } else {
                    Image(systemName: "person")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 100))
                }
            }
            .frame(height: 200)

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

            if !skills.isEmpty {
                DatabaseRecordInfoSection("Skills", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(skills) { skill in
                            NavigationLink(value: skill) {
                                SkillCell(skill: skill)
                            }
                        }
                    }
                    .padding(.vertical, 20)
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
        .task {
            await loadJobInfo()
        }
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

    private func loadJobInfo() async {
        jobImage = await ClientResourceManager.shared.jobImage(gender: .male, job: jobStats.job)

        let skillDatabase = SkillDatabase.database(for: mode)
        let skillTreeDatabase = SkillTreeDatabase.database(for: mode)

        if let skillTree = try? await skillTreeDatabase.skillTree(forJobID: jobStats.job.id)?.tree {
            var skills: [Skill] = []
            for s in skillTree {
                if let skill = try? await skillDatabase.skill(forAegisName: s.name) {
                    skills.append(skill)
                }
            }
            self.skills = skills
        }
    }
}
