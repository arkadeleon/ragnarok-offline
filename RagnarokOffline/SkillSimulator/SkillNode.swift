//
//  SkillNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/11.
//

import RagnarokConstants

struct SkillNode: Identifiable, Hashable {
    struct Prerequisite: Hashable {
        var aegisName: String
        var displayName: String
        var level: Int
    }

    enum Source: Hashable {
        case direct(jobID: JobID, jobName: String)
        case inherited(jobID: JobID, jobName: String)

        var jobID: JobID {
            switch self {
            case .direct(let jobID, _):
                jobID
            case .inherited(let jobID, _):
                jobID
            }
        }

        var jobName: String {
            switch self {
            case .direct(_, let jobName):
                jobName
            case .inherited(_, let jobName):
                jobName
            }
        }
    }

    var aegisName: String
    var displayName: String
    var maxLevel: Int
    var requiredBaseLevel: Int
    var requiredJobLevel: Int
    var prerequisites: [Prerequisite]
    var source: Source

    var id: String {
        aegisName
    }
}
