//
//  JobDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct JobDetailView: View {
    let database: Database
    let jobStats: JobStats

    var body: some View {
        List {
            Section("Info") {
                LabeledContent("Max Weight", value: "#\(jobStats.maxWeight)")
                LabeledContent("HP Factor", value: "\(jobStats.hpFactor)")
                LabeledContent("HP Increase", value: "\(jobStats.hpIncrease)")
                LabeledContent("SP Increase", value: "\(jobStats.spIncrease)")
            }
        }
        .listStyle(.plain)
        .navigationTitle(jobStats.job.description)
        .navigationBarTitleDisplayMode(.inline)
    }
}
