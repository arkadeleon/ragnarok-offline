//
//  JobDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import ROGenerated
import rAthenaCommon
import rAthenaResources

public actor JobDatabase {
    public static let prerenewal = JobDatabase(mode: .prerenewal)
    public static let renewal = JobDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> JobDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedJobs: [JobStats] = []

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func jobs() throws -> [JobStats] {
        if cachedJobs.isEmpty {
            let decoder = YAMLDecoder()

            let basicStatsURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("job_stats.yml")
            let basicStatsData = try Data(contentsOf: basicStatsURL)
            let basicStatsList = try decoder.decode(ListNode<JobBasicStats>.self, from: basicStatsData).body

            let aspdStatsURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("job_aspd.yml")
            let aspdStatsData = try Data(contentsOf: aspdStatsURL)
            let aspdStatsList = try decoder.decode(ListNode<JobASPDStats>.self, from: aspdStatsData).body

            let expStatsURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("job_exp.yml")
            let expStatsData = try Data(contentsOf: expStatsURL)
            let expStatsList = try decoder.decode(ListNode<JobExpStats>.self, from: expStatsData).body

            let basePointsStatsURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("job_basepoints.yml")
            let basePointsStatsData = try Data(contentsOf: basePointsStatsURL)
            let basePointsStatsList = try decoder.decode(ListNode<JobBasePointsStats>.self, from: basePointsStatsData).body

            cachedJobs = Job.allCases.compactMap { job in
                JobStats(
                    job: job,
                    basicStatsList: basicStatsList,
                    aspdStatsList: aspdStatsList,
                    expStatsList: expStatsList,
                    basePointsStatsList: basePointsStatsList
                )
            }
        }

        return cachedJobs
    }
}
