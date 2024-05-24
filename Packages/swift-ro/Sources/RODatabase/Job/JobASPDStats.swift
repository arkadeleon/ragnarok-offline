//
//  JobASPDStats.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

struct JobASPDStats: Decodable {

    /// List of jobs associated to group.
    var jobs: [Job]

    /// Base ASPD for each weapon type. (Default: 2000)
    var baseASPD: [WeaponType : Int]

    enum CodingKeys: String, CodingKey {
        case jobs = "Jobs"
        case baseASPD = "BaseASPD"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jobs = try container.decode(PairsNode<Job, Bool>.self, forKey: .jobs).keys
        self.baseASPD = try container.decode(PairsNode<WeaponType, Int>.self, forKey: .baseASPD).dictionary
    }
}
