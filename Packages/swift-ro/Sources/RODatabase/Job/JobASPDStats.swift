//
//  JobASPDStats.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import ROGenerated

struct JobASPDStats: Decodable {

    /// List of jobs associated to group.
    var jobs: Set<JobID>

    /// Base ASPD for each weapon type. (Default: 2000)
    var baseASPD: [WeaponType : Int]

    enum CodingKeys: String, CodingKey {
        case jobs = "Jobs"
        case baseASPD = "BaseASPD"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.jobs = try container.decode([JobID : Bool].self, forKey: .jobs).unorderedKeys
        self.baseASPD = try container.decode([WeaponType : Int].self, forKey: .baseASPD)
    }
}
