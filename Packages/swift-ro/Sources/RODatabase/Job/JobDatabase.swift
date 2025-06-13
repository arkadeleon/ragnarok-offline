//
//  JobDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML
import rAthenaResources
import ROConstants

public actor JobDatabase {
    public static let prerenewal = JobDatabase(mode: .prerenewal)
    public static let renewal = JobDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> JobDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private lazy var _jobs: [Job] = {
        metric.beginMeasuring("Load job database")

        do {
            let decoder = YAMLDecoder()

            let basicStatsURL = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/job_stats.yml")
            let basicStatsData = try Data(contentsOf: basicStatsURL)
            let basicStatsList = try decoder.decode(ListNode<JobBasicStats>.self, from: basicStatsData).body

            let aspdStatsURL = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/job_aspd.yml")
            let aspdStatsData = try Data(contentsOf: aspdStatsURL)
            let aspdStatsList = try decoder.decode(ListNode<JobASPDStats>.self, from: aspdStatsData).body

            let expStatsURL = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/job_exp.yml")
            let expStatsData = try Data(contentsOf: expStatsURL)
            let expStatsList = try decoder.decode(ListNode<JobExpStats>.self, from: expStatsData).body

            let basePointsStatsURL = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/job_basepoints.yml")
            let basePointsStatsData = try Data(contentsOf: basePointsStatsURL)
            let basePointsStatsList = try decoder.decode(ListNode<JobBasePointsStats>.self, from: basePointsStatsData).body

            let jobs = JobID.allCases.compactMap { jobID in
                Job(
                    jobID: jobID,
                    basicStatsList: basicStatsList,
                    aspdStatsList: aspdStatsList,
                    expStatsList: expStatsList,
                    basePointsStatsList: basePointsStatsList
                )
            }

            metric.endMeasuring("Load job database")

            return jobs
        } catch {
            metric.endMeasuring("Load job database", error)

            return []
        }
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func jobs() -> [Job] {
        _jobs
    }
}
