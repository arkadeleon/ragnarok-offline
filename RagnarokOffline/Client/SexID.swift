//
//  SexID.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/8.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaCommon

struct SexID: RawRepresentable {
    let rawValue: Int

    var resourceName: String {
        switch rawValue {
        case RA_SEX_FEMALE: "여"
        case RA_SEX_MALE: "남"
        default: ""
        }
    }
}
