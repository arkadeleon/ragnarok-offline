//
//  SkillSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/11.
//

import RagnarokConstants
import SwiftUI

struct SkillSimulatorView: View {
    private struct SkillGroup: Identifiable {
        var jobID: JobID
        var title: String
        var skillNodes: [SkillNode]

        var id: JobID {
            jobID
        }
    }

    @Environment(DatabaseModel.self) private var database
    @Environment(SkillSimulator.self) private var skillSimulator

    @State private var inlineErrorBySkill: [String: String] = [:]

    var body: some View {
        @Bindable var skillSimulator = skillSimulator

        Form {
            Section {
                Picker(selection: $skillSimulator.selectedJobID) {
                    ForEach(database.jobs) { job in
                        Text(job.displayName).tag(job.id)
                    }
                } label: {
                    Text("Job", tableName: "SkillSimulator")
                }
                .disabled(database.jobs.isEmpty)
                .onChange(of: skillSimulator.selectedJobID) { oldValue, newValue in
                    inlineErrorBySkill = [:]
                    skillSimulator.selectJob(
                        newValue,
                        jobs: database.jobs,
                        skills: database.skills,
                        resetAllocations: oldValue != newValue
                    )
                }

                let baseLevel = Binding(
                    get: { skillSimulator.baseLevel },
                    set: { skillSimulator.updateBaseLevel($0) }
                )

                Stepper(value: baseLevel, in: 1...skillSimulator.maxBaseLevel) {
                    Text("Base Lv: \(skillSimulator.baseLevel)", tableName: "SkillSimulator")
                }

                ForEach(skillSimulator.jobStages) { stage in
                    let jobLevel = Binding(
                        get: { skillSimulator.jobLevel(for: stage.jobID) },
                        set: { skillSimulator.updateJobLevel($0, for: stage.jobID) }
                    )
                    let minimumJobLevel = skillSimulator.minimumJobLevel(for: stage.jobID)

                    Stepper(value: jobLevel, in: minimumJobLevel...stage.maxJobLevel) {
                        Text("\(stage.displayName) Job Lv: \(skillSimulator.jobLevel(for: stage.jobID))", tableName: "SkillSimulator")
                    }

                    HStack {
                        Text("\(stage.displayName) Points", tableName: "SkillSimulator")
                        Spacer()
                        Text(verbatim: "\(skillSimulator.spentPoints(for: stage.jobID)) / \(skillSimulator.totalPoints(for: stage.jobID))")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Total Points", tableName: "SkillSimulator")
                    Spacer()
                    Text(verbatim: "\(skillSimulator.spentPoints) / \(skillSimulator.totalPoints)")
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(skillGroups(for: skillSimulator)) { group in
                Section {
                    ForEach(group.skillNodes) { skillNode in
                        SkillRowView(
                            skillNode: skillNode,
                            currentLevel: skillSimulator.skillLevel(for: skillNode.aegisName),
                            levelTemplate: levelTemplate(for: skillSimulator),
                            isIncrementEnabled: skillSimulator.isIncrementEnabled(for: skillNode),
                            isDecrementEnabled: skillSimulator.isDecrementEnabled(for: skillNode),
                            inlineError: inlineErrorBySkill[skillNode.aegisName],
                            lockReason: skillSimulator.lockReason(for: skillNode),
                            onIncrement: {
                                if let error = skillSimulator.incrementSkill(named: skillNode.aegisName) {
                                    presentInlineError(error.localizedDescription, for: skillNode.aegisName)
                                }
                            },
                            onDecrement: {
                                if let error = skillSimulator.decrementSkill(named: skillNode.aegisName) {
                                    presentInlineError(error.localizedDescription, for: skillNode.aegisName)
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                } header: {
                    Text("\(group.title) Skills", tableName: "SkillSimulator")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Skill Simulator", tableName: "SkillSimulator"))
        .toolbar {
            ToolbarItem {
                Button {
                    skillSimulator.reset()
                    inlineErrorBySkill = [:]
                } label: {
                    Text("Reset", tableName: "SkillSimulator")
                }
                .disabled(skillSimulator.spentPoints == 0)
            }
        }
        .overlay {
            if database.jobs.isEmpty {
                ProgressView()
            }
        }
        .task {
            await database.fetchJobs()
            await database.fetchSkills()
            skillSimulator.bootstrap(jobs: database.jobs, skills: database.skills)
        }
    }

    private func levelTemplate(for simulator: SkillSimulator) -> String {
        let maxLevel = simulator.skillNodes.map(\.maxLevel).max() ?? 10
        let digitCount = max(String(maxLevel).count, 1)
        let unit = String(repeating: "0", count: digitCount)
        return "\(unit) / \(unit)"
    }

    private func skillGroups(for simulator: SkillSimulator) -> [SkillGroup] {
        let groupedNodes = Dictionary(
            grouping: simulator.skillNodes,
            by: { $0.source.jobID }
        )

        var groups: [SkillGroup] = []

        for stage in simulator.jobStages {
            guard let skillNodes = groupedNodes[stage.jobID], !skillNodes.isEmpty else {
                continue
            }

            let group = SkillGroup(jobID: stage.jobID, title: stage.displayName, skillNodes: skillNodes)
            groups.append(group)
        }

        return groups
    }

    private func presentInlineError(_ message: String, for skillName: String) {
        inlineErrorBySkill[skillName] = message

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            if inlineErrorBySkill[skillName] == message {
                inlineErrorBySkill.removeValue(forKey: skillName)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SkillSimulatorView()
    }
    .environment(DatabaseModel(mode: .renewal))
    .environment(SkillSimulator())
}
