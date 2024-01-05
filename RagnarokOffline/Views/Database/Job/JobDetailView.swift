//
//  JobDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/5.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaMap

struct JobDetailView: View {
    let job: RAJob

    var body: some View {
        List {
            Section("Info") {
                DatabaseRecordField(name: "Max Weight", value: "#\(job.maxWeight)")
                DatabaseRecordField(name: "HP Factor", value: "\(job.hpFactor)")
                DatabaseRecordField(name: "HP Increase", value: "\(job.hpIncrease)")
                DatabaseRecordField(name: "SP Increase", value: "\(job.spIncrease)")
            }
        }
        .listStyle(.plain)
        .navigationTitle(job.jobName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JobDetailView(job: RAJob())
}
