//
//  JobDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobDetailView: View {
    var job: JobModel

    @Environment(DatabaseModel.self) private var database

    @State private var skills: [SkillModel] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let animatedImage = job.animatedImage, let firstFrame = animatedImage.firstFrame {
                    Image(firstFrame, scale: animatedImage.scale, label: Text(job.displayName))
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            DatabaseRecordSectionView(attributes: job.attributes) {
                Text("Info", tableName: "Database")
            }

            DatabaseRecordSectionView(attributes: job.baseASPD) {
                Text("Base ASPD", tableName: "Database")
            }

            DatabaseRecordSectionView {
                LazyVStack(spacing: 10) {
                    ForEach(job.baseLevels.prefix(10)) { levelStats in
                        HStack {
                            Text("Level \(levelStats.level)", tableName: "Database")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text("Exp \(levelStats.baseExp.formatted())", tableName: "Database")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            } header: {
                NavigationLink {
                    BaseLevelTableView(job: job)
                } label: {
                    HStack {
                        Text("Base Levels", tableName: "Database")
                            .foregroundStyle(Color.primary)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }

            DatabaseRecordSectionView {
                LazyVStack(spacing: 10) {
                    ForEach(job.jobLevels.prefix(10)) { levelStats in
                        HStack {
                            Text("Level \(levelStats.level)", tableName: "Database")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text("Exp \(levelStats.jobExp.formatted())", tableName: "Database")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            } header: {
                NavigationLink {
                    JobLevelTableView(job: job)
                } label: {
                    HStack {
                        Text("Job Levels", tableName: "Database")
                            .foregroundStyle(Color.primary)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }

            if !skills.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(skills) { skill in
                            NavigationLink(value: skill) {
                                SkillCell(skill: skill)
                            }
                        }
                    }
                } header: {
                    Text("Skills", tableName: "Database")
                }
            }
        }
        .navigationTitle(job.displayName)
        .task {
            await job.fetchAnimatedImage()
        }
        .task {
            skills = await database.skills(for: job.id)
        }
    }
}
