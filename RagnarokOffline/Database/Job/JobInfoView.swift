//
//  JobInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI
import ROClientResources
import RODatabase
import ROGenerated
import rAthenaCommon

struct JobInfoView: View {
    var mode: ServerMode
    var job: Job

    typealias BaseLevelStats = (level: Int, baseExp: Int, baseHp: Int, baseSp: Int)
    typealias JobLevelStats = (level: Int, jobExp: Int, bonusStats: String)

    @State private var jobImage: CGImage?
    @State private var skills: [Skill] = []

    var body: some View {
        ScrollView {
            ZStack {
                if let jobImage {
                    Image(jobImage, scale: 1, label: Text(job.id.stringValue))
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)

            DatabaseRecordInfoSection("Info") {
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

            DatabaseRecordInfoSection("Base ASPD") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(baseASPD) { baseASPD in
                        LabeledContent {
                            Text(baseASPD.value)
                        } label: {
                            Text(baseASPD.name)
                        }
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
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            DatabaseRecordInfoSection {
                LazyVStack(spacing: 10) {
                    ForEach(baseLevels, id: \.level) { levelStats in
                        HStack {
                            Text((levelStats.level + 1).formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text(levelStats.baseExp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.baseHp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.baseSp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
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
                            Text((levelStats.level + 1).formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text(levelStats.jobExp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.bonusStats)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(verbatim: "")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
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

                    Text(verbatim: "")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .background(.background)
        .navigationTitle(job.id.stringValue)
        .task {
            await loadJobInfo()
        }
    }

    private var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "Max Weight", value: job.maxWeight))
        attributes.append(.init(name: "HP Factor", value: job.hpFactor))
        attributes.append(.init(name: "HP Increase", value: job.hpIncrease))
        attributes.append(.init(name: "SP Increase", value: job.spIncrease))

        return attributes
    }

    private var baseASPD: [DatabaseRecordAttribute] {
        WeaponType.allCases.compactMap { weaponType in
            if let aspd = job.baseASPD[weaponType] {
                DatabaseRecordAttribute(name: weaponType.localizedStringResource, value: aspd)
            } else {
                nil
            }
        }
    }

    private var baseLevels: [BaseLevelStats] {
        (0..<job.maxBaseLevel).map { level in
            (level, job.baseExp[level], job.baseHp[level], job.baseSp[level])
        }
    }

    private var jobLevels: [JobLevelStats] {
        (0..<job.maxJobLevel).map { level in
            let bonusStats = Parameter.allCases.compactMap { parameter in
                if let value = job.bonusStats[level][parameter], value > 0 {
                    return "\(parameter.stringValue)(+\(value))"
                } else {
                    return nil
                }
            }.joined(separator: " ")
            return (level, job.jobExp[level], bonusStats)
        }
    }

    private func loadJobInfo() async {
        jobImage = await ClientResourceManager.default.jobImage(sex: .male, jobID: job.id)

        let skillDatabase = SkillDatabase.database(for: mode)
        let skillTreeDatabase = SkillTreeDatabase.database(for: mode)

        if let skillTree = try? await skillTreeDatabase.skillTree(forJobID: job.id)?.tree {
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
