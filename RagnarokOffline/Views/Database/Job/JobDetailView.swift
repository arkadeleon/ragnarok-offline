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
    let jobStats: JobStats

    var body: some View {
        List {
            Section("Info") {
                DatabaseRecordField(name: "Max Weight", value: "#\(jobStats.maxWeight)")
                DatabaseRecordField(name: "HP Factor", value: "\(jobStats.hpFactor)")
                DatabaseRecordField(name: "HP Increase", value: "\(jobStats.hpIncrease)")
                DatabaseRecordField(name: "SP Increase", value: "\(jobStats.spIncrease)")
            }
        }
        .listStyle(.plain)
        .navigationTitle(jobStats.job.description)
        .navigationBarTitleDisplayMode(.inline)
    }
}
