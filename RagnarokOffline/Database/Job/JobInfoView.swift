//
//  JobInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//

import SwiftUI

struct JobInfoView: View {
    var job: ObservableJob

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ZStack {
                    if let animatedImage = job.animatedImage, let firstFrame = animatedImage.firstFrame {
                        Image(firstFrame, scale: animatedImage.frameScale, label: Text(job.displayName))
                    } else {
                        Image(systemName: "person")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)

                DatabaseRecordAttributesSectionView("Info", attributes: job.attributes)

                DatabaseRecordAttributesSectionView("Base ASPD", attributes: job.baseASPD)

                if !job.skills.isEmpty {
                    DatabaseRecordSectionView("Skills", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(job.skills) { skill in
                                NavigationLink(value: skill) {
                                    SkillCell(skill: skill)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                DatabaseRecordSectionView {
                    LazyVStack(spacing: 10) {
                        ForEach(job.baseLevels) { levelStats in
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

                DatabaseRecordSectionView {
                    LazyVStack(spacing: 10) {
                        ForEach(job.jobLevels) { levelStats in
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
        }
        .background(.background)
        .navigationTitle(job.displayName)
        .task {
            await job.fetchAnimatedImage()
            await job.fetchDetail()
        }
    }
}
