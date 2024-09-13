//
//  JobASPDStats.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

struct JobASPDStats: Decodable {

    /// List of jobs associated to group.
    var jobs: Set<Job>

    /// Base ASPD for each weapon type. (Default: 2000)
    var baseASPD: [WeaponType : Int]

    enum CodingKeys: String, CodingKey {
        case jobs = "Jobs"
        case baseASPD = "BaseASPD"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let jobs = try container.decode([String : Bool].self, forKey: .jobs)
        self.jobs = Set<Job>(from: jobs)

        self.baseASPD = try container.decode([WeaponType : Int].self, forKey: .baseASPD)
    }
}
